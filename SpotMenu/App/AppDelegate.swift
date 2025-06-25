import Cocoa
import Combine
import KeyboardShortcuts
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var statusItemModel = StatusItemModel()
    var playerPreferencesModel = PlayerPreferencesModel()
    var playbackModel: PlaybackModel!
    var visualPreferencesModel = VisualPreferencesModel()
    var popoverManager: PopoverManager!
    var preferencesWindow: NSWindow?
    var eventMonitor: Any?
    var visualPreferencesModelCancellable: AnyCancellable?
    var isUsingCustomStatusView = false
    var spotifyIcon: NSImage?
    var appleMusicIcon: NSImage?
    var hudWindow: NSWindow?
    var hudHostingController: NSHostingController<NowPlayingHUDView>?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        playbackModel = PlaybackModel(preferences: playerPreferencesModel)

        let circularAppleMusicIcon = Image("AppleMusicIcon")
            .resizable()
            .frame(width: 16, height: 16)
            .clipShape(Circle())

        if let rendered = nsImage(
            from: circularAppleMusicIcon,
            size: CGSize(width: 16, height: 16)
        ) {
            appleMusicIcon = rendered
            appleMusicIcon?.isTemplate = true
            appleMusicIcon?.size = NSSize(width: 16, height: 16)
        }

        spotifyIcon = NSImage(named: "SpotifyIcon")
        spotifyIcon?.isTemplate = true
        spotifyIcon?.size = NSSize(width: 16, height: 16)

        // Configure status item and button
        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )

        // Handle right-click menu
        NSEvent.addLocalMonitorForEvents(matching: [.rightMouseUp]) {
            [weak self] event in
            self?.handleRightClick(event: event)
            return nil
        }

        // Observe playback updates
        NotificationCenter.default.addObserver(
            forName: .contentModelDidUpdate,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateStatusItem()
        }

        // Set up popover manager
        let playbackView = PlaybackView(model: playbackModel)
        popoverManager = PopoverManager(contentView: playbackView)

        // Global event monitor to dismiss popover
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [
            .leftMouseDown, .rightMouseDown,
        ]) { [weak self] _ in
            self?.popoverManager.dismiss()
        }

        // Update UI periodically
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            [weak self] _ in
            self?.updateStatusItem()
        }

        StatusItemConfigurator.configure(
            statusItem: statusItem,
            statusItemModel: statusItemModel,
            visualPreferencesModel: visualPreferencesModel,
            playBackModel: playbackModel,
            toggleAction: #selector(togglePopover),
            target: self
        )

        setupKeyboardShortcuts()
        updateStatusItem()

        visualPreferencesModelCancellable = visualPreferencesModel
            .objectWillChange.sink { [weak self] _ in
                self?.updateStatusItem()
            }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    private func setupKeyboardShortcuts() {
        KeyboardShortcuts.onKeyUp(for: .playPause) { [weak self] in
            self?.playbackModel.togglePlayPause()
        }
        KeyboardShortcuts.onKeyUp(for: .nextTrack) { [weak self] in
            self?.playbackModel.skipForward()
        }
        KeyboardShortcuts.onKeyUp(for: .previousTrack) { [weak self] in
            self?.playbackModel.skipBack()
        }
        KeyboardShortcuts.onKeyUp(for: .showNowPlayingHUD) { [weak self] in
            if self?.hudWindow != nil {
                self?.dismissHUD()
                return
            }
            self?.showNowPlayingHUD()
        }
    }

    func updateStatusItem() {
        statusItemModel.artist = playbackModel.artist
        statusItemModel.title = playbackModel.title
        statusItemModel.isPlaying = playbackModel.isPlaying

        StatusItemConfigurator.updateWidth(
            statusItem: statusItem,
            maxWidth: visualPreferencesModel.maxStatusItemWidth
        )
    }

    @objc func togglePopover() {
        popoverManager.toggle(relativeTo: statusItem.button)
    }

    private func handleRightClick(event: NSEvent) {
        guard let button = statusItem.button,
            button.frame.contains(
                button.convert(event.locationInWindow, from: nil)
            )
        else { return }

        popoverManager.dismiss()
        statusItem.menu = MenuBuilder.build(delegate: self)
        button.performClick(nil)
        statusItem.menu = nil
    }

    @objc func refreshAction() {
        playbackModel.fetchInfo()
    }

    @objc func preferencesAction() {
        if preferencesWindow == nil {
            let hosting = NSHostingView(
                rootView: PreferencesView(
                    visualPreferencesModel: visualPreferencesModel,
                    playbackModel: playbackModel,
                    playerPreferencesModel: playerPreferencesModel
                )
            )
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 420, height: 240),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.center()
            window.title = "Preferences"
            window.contentView = hosting
            window.isReleasedWhenClosed = false
            window.level = .normal
            preferencesWindow = window
        }

        preferencesWindow?.makeKeyAndOrderFront(nil)
        preferencesWindow?.makeMain()
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }

    func showNowPlayingHUD() {
        guard hudWindow == nil else { return }

        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        let isVisible = Binding<Bool>(
            get: { self.hudWindow != nil },
            set: { visible in
                if !visible {
                    self.dismissHUD()
                }
            }
        )

        let hudRootView = NowPlayingHUDView(
            model: playbackModel,
            isVisible: isVisible
        )
        let controller = NSHostingController(rootView: hudRootView)

        controller.view.wantsLayer = true
        controller.view.layer?.cornerRadius = 0
        controller.view.layer?.masksToBounds = true

        let screenFrame =
            NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 800, height: 600)

        let window = HUDWindow(
            contentRect: screenFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .mainMenu + 1
        window.hasShadow = false
        window.ignoresMouseEvents = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let captureView = HUDKeyCaptureView(frame: screenFrame)
        captureView.onEscapePressed = { [weak self] in
            withAnimation {
                self?.dismissHUD()
            }
        }
        captureView.onRightArrowPressed = { [weak self] in
            withAnimation {
                self?.playbackModel.skipForward()
            }
        }
        captureView.onLeftArrowPressed = { [weak self] in
            withAnimation {
                self?.playbackModel.skipBack()
            }
        }
        captureView.onSpacebarPressed = { [weak self] in
            withAnimation {
                self?.playbackModel.togglePlayPause()
            }
        }

        controller.view.frame = screenFrame
        captureView.addSubview(controller.view)

        window.contentView = captureView
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(captureView)
        NSApp.activate(ignoringOtherApps: true)

        self.hudWindow = window
        self.hudHostingController = controller
    }

    func dismissHUD() {
        guard let window = hudWindow else { return }

        NSAnimationContext.runAnimationGroup(
            { context in
                context.duration = 0.3
                context.timingFunction = CAMediaTimingFunction(
                    name: .easeInEaseOut
                )
                window.animator().alphaValue = 0
            },
            completionHandler: {
                window.orderOut(nil)
                self.hudWindow = nil
                self.hudHostingController = nil
            }
        )
    }
}

// MARK: - Custom NSWindow subclass
class HUDWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

// MARK: - HUDKeyCaptureView
class HUDKeyCaptureView: NSView {
    var onEscapePressed: (() -> Void)?
    var onLeftArrowPressed: (() -> Void)?
    var onRightArrowPressed: (() -> Void)?
    var onSpacebarPressed: (() -> Void)?

    override var acceptsFirstResponder: Bool { true }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 53:  // Escape
            onEscapePressed?()
        case 123:  // Left Arrow
            onLeftArrowPressed?()
        case 124:  // Right Arrow
            onRightArrowPressed?()
        case 49:  // Spacebar
            onSpacebarPressed?()
        default:
            super.keyDown(with: event)
        }
    }

    override func viewDidMoveToWindow() {
        window?.makeFirstResponder(self)
    }
}

// MARK: - Image renderer helper
func nsImage<Content: View>(
    from view: Content,
    size: CGSize,
    scale: CGFloat = 1.0
) -> NSImage? {
    let hostingView = NSHostingView(rootView: view)
    hostingView.frame = CGRect(origin: .zero, size: size)

    guard
        let rep = hostingView.bitmapImageRepForCachingDisplay(
            in: hostingView.bounds
        )
    else {
        return nil
    }

    hostingView.cacheDisplay(in: hostingView.bounds, to: rep)

    let image = NSImage(size: size)
    image.addRepresentation(rep)

    return image
}
