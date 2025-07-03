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
    var spotifyIcon: NSImage?
    var appleMusicIcon: NSImage?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        playbackModel = PlaybackModel(preferences: musicPlayerPreferencesModel)

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
        }
        KeyboardShortcuts.onKeyUp(for: .nextTrack) { [weak self] in
            self?.playbackModel.skipForward()
        }
        KeyboardShortcuts.onKeyUp(for: .previousTrack) { [weak self] in
            self?.playbackModel.skipBack()
        }
        KeyboardShortcuts.onKeyUp(for: .toggleLike) { [weak self] in
            self?.playbackModel.toggleLiked()
        }
        KeyboardShortcuts.onKeyUp(for: .likeTrack) { [weak self] in
            self?.playbackModel.likeTrack()
        }
        KeyboardShortcuts.onKeyUp(for: .unlikeTrack) { [weak self] in
            self?.playbackModel.unlikeTrack()
        }
    }

    func updateStatusItem() {
        statusItemModel.artist = playbackModel.artist
        statusItemModel.title = playbackModel.title
        statusItemModel.isPlaying = playbackModel.isPlaying
        statusItemModel.isLiked = playbackModel.isLiked

        StatusItemConfigurator.updateWidth(
            statusItem: statusItem,
            maxWidth: menuBarPreferencesModel.maxStatusItemWidth
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
                    menuBarPreferencesModel: menuBarPreferencesModel,
                    playbackModel: playbackModel,
                    musicPlayerPreferencesModel: musicPlayerPreferencesModel,
                    playbackAppearancePreferencesModel:
                        playbackAppearancePreferencesModel
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
