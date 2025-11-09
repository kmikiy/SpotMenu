import Combine
import KeyboardShortcuts
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var statusItemModel = StatusItemModel()
    var playbackAppearancePreferencesModel =
        PlaybackAppearancePreferencesModel()
    var musicPlayerPreferencesModel = MusicPlayerPreferencesModel()
    var playbackModel: PlaybackModel!
    var menuBarPreferencesModel = MenuBarPreferencesModel()
    var popoverManager: PopoverManager!
    var preferencesWindow: NSWindow?
    var eventMonitor: Any?
    var menuBarPreferencesModelCancellable: AnyCancellable?
    var isUsingCustomStatusView = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        playbackModel = PlaybackModel(preferences: musicPlayerPreferencesModel)

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
        let playbackView = PlaybackView(
            model: playbackModel,
            preferences: playbackAppearancePreferencesModel,
            musicPlayerPreferencesModel: musicPlayerPreferencesModel
        )
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
            menuBarPreferencesModel: menuBarPreferencesModel,
            musicPlayerPreferencesModel: musicPlayerPreferencesModel,
            playBackModel: playbackModel,
            toggleAction: #selector(togglePopover),
            target: self
        )

        setupKeyboardShortcuts()
        updateStatusItem()

        menuBarPreferencesModelCancellable = menuBarPreferencesModel
            .objectWillChange.sink { [weak self] _ in
                self?.updateStatusItem()
            }
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else { return }
        SpotifyAuthManager.shared.handleRedirect(url: url)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    private func setupKeyboardShortcuts() {
        KeyboardShortcuts.onKeyUp(for: .playPause) { [weak self] in
            self?.playbackModel.togglePlayPause()
            // Immediately update status item for keyboard shortcut feedback
            DispatchQueue.main.async {
                self?.updateStatusItem()
            }
        }
        KeyboardShortcuts.onKeyUp(for: .nextTrack) { [weak self] in
            self?.playbackModel.skipForward()
            // Immediately update status item for keyboard shortcut feedback
            DispatchQueue.main.async {
                self?.updateStatusItem()
            }
        }
        KeyboardShortcuts.onKeyUp(for: .previousTrack) { [weak self] in
            self?.playbackModel.skipBack()
            // Immediately update status item for keyboard shortcut feedback
            DispatchQueue.main.async {
                self?.updateStatusItem()
            }
        }
        KeyboardShortcuts.onKeyUp(for: .toggleLike) { [weak self] in
            self?.playbackModel.toggleLiked()
            // Immediately update status item for keyboard shortcut feedback
            DispatchQueue.main.async {
                self?.updateStatusItem()
            }
        }
        KeyboardShortcuts.onKeyUp(for: .likeTrack) { [weak self] in
            self?.playbackModel.likeTrack()
            // Immediately update status item for keyboard shortcut feedback
            DispatchQueue.main.async {
                self?.updateStatusItem()
            }
        }
        KeyboardShortcuts.onKeyUp(for: .unlikeTrack) { [weak self] in
            self?.playbackModel.unlikeTrack()
            // Immediately update status item for keyboard shortcut feedback
            DispatchQueue.main.async {
                self?.updateStatusItem()
            }
        }
    }

    func updateStatusItem() {
        // Update status item model first
        statusItemModel.artist = playbackModel.artist
        statusItemModel.title = playbackModel.title
        statusItemModel.isPlaying = playbackModel.isPlaying
        statusItemModel.isLiked = playbackModel.isLiked
        statusItemModel.playerIconName = playbackModel.playerIconName

        // Update width immediately and synchronously after model changes
        StatusItemConfigurator.updateWidth(
            statusItem: statusItem,
            maxWidth: menuBarPreferencesModel.maxStatusItemWidth
        )
        
        // Force immediate layout update to prevent truncation flash
        statusItem.button?.needsLayout = true
        statusItem.button?.layoutSubtreeIfNeeded()
        
        // Ensure the hosting view updates its layout immediately
        if let hostingView = statusItem.button?.subviews.compactMap({ $0 as? NSHostingView<StatusItemView> }).first {
            hostingView.needsLayout = true
            hostingView.layoutSubtreeIfNeeded()
        }
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
            let hostingController = NSHostingController(
                rootView: PreferencesView(
                    menuBarPreferencesModel: menuBarPreferencesModel,
                    playbackModel: playbackModel,
                    musicPlayerPreferencesModel: musicPlayerPreferencesModel,
                    playbackAppearancePreferencesModel:
                        playbackAppearancePreferencesModel
                )
            )

            let window = NSWindow(contentViewController: hostingController)
            window.title = "Settings"
            window.styleMask = [
                .titled, .closable, .miniaturizable, .resizable,
                .fullSizeContentView,
            ]
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden

            // Configure toolbar for modern macOS look
            let toolbar = NSToolbar(identifier: "PreferencesToolbar")
            toolbar.displayMode = .iconOnly
            window.toolbar = toolbar
            window.toolbarStyle = .unified

            // Set window size
            window.setContentSize(NSSize(width: 700, height: 500))
            window.minSize = NSSize(width: 600, height: 400)
            window.center()
            window.isReleasedWhenClosed = false
            window.level = .normal

            // Modern rounded corners
            window.backgroundColor = .clear
            window.isOpaque = false

            preferencesWindow = window
        }

        preferencesWindow?.makeKeyAndOrderFront(nil)
        preferencesWindow?.makeMain()
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }

}

func nsImage<Content: View>(
    from view: Content,
    size: CGSize,
    scale: CGFloat = 1.0
) -> NSImage? {
    let hostingView = NSHostingView(rootView: view)
    hostingView.frame = CGRect(origin: .zero, size: size)

    let rep = hostingView.bitmapImageRepForCachingDisplay(
        in: hostingView.bounds
    )
    guard let imageRep = rep else { return nil }

    hostingView.cacheDisplay(in: hostingView.bounds, to: imageRep)

    let nsImage = NSImage(size: size)
    nsImage.addRepresentation(imageRep)

    return nsImage
}
