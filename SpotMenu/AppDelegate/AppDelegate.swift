//
//  AppDelegate.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 02/09/16.
//  Copyright © 2016 KM. All rights reserved.
//

import AppKit.NSAppearance
import Carbon.HIToolbox
import Cocoa
import MusicPlayer
import Sparkle

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties

    private var hudController: HudWindowController?
    private var preferencesController: NSWindowController?
    private var hiddenController: NSWindowController?
    private let popover = NSPopover()

    // private let popoverDelegate = PopOverDelegate()

    private var eventMonitor: EventMonitor?
    //private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let statusItem = NSStatusBar.system.statusItem(withLength: 150) //TODO: use length from settings
    private let menuBar : MenuBar = NSView.fromNib(name: "MenuBar")
    private let issuesURL = URL(string: "https://github.com/kmikiy/SpotMenu/issues")
    private let kmikiyURL = URL(string: "https://github.com/kmikiy")
    private let menu = StatusMenu().menu
    private let spotMenuIcon = NSImage(named: NSImage.Name(rawValue: "StatusBarButtonImage"))
    private let spotMenuIconItunes = NSImage(named: NSImage.Name(rawValue: "StatusBarButtonImageItunes"))
    private var lastStatusTitle: String = ""
    private var removeHudTimer: Timer?
    private var musicPlayerManager: MusicPlayerManager!
    private var statusItemBuilder = StatusItemBuilder(title: "", artist: "", albumName: "", isPlaying: false)


    // MARK: - AppDelegate methods

    func applicationDidFinishLaunching(_: Notification) {

        statusItem.view = menuBar

        
        UserPreferences.initializeUserPreferences()

        musicPlayerManager = MusicPlayerManager()
        musicPlayerManager.add(musicPlayer: .spotify)
        musicPlayerManager.add(musicPlayer: .iTunes)

        musicPlayerManager.delegate = self
        let lastMusicPlayerName = MusicPlayerName(rawValue: UserPreferences.lastMusicPlayer)!
        let lastMusicPlayer = musicPlayerManager.existMusicPlayer(with: lastMusicPlayerName)
        musicPlayerManager.currentPlayer = lastMusicPlayer

        let popoverVC = PopOverViewController(nibName: NSNib.Name(rawValue: "PopOver"), bundle: nil)
        popoverVC.setUpMusicPlayerManager()
        popover.contentViewController = popoverVC
        // popover.delegate = popoverDelegate

        hiddenController = (NSStoryboard(name: NSStoryboard.Name(rawValue: "Hidden"), bundle: nil).instantiateInitialController() as! NSWindowController)
        hiddenController?.window?.isOpaque = false
        hiddenController?.window?.backgroundColor = .clear
        hiddenController?.window?.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)))
        hiddenController?.window?.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        hiddenController?.window?.ignoresMouseEvents = true

        if let button = statusItem.button {
            button.image = chooseIcon(musicPlayerName: MusicPlayerName(rawValue: UserPreferences.lastMusicPlayer)!)

            button.sendAction(on: [NSEvent.EventTypeMask.leftMouseUp, NSEvent.EventTypeMask.rightMouseUp])
            button.action = #selector(AppDelegate.togglePopover(_:))
            updateTitle()
        }

        eventMonitor = EventMonitor(mask: [NSEvent.EventTypeMask.leftMouseDown, NSEvent.EventTypeMask.rightMouseDown]) { [unowned self] event in
            if self.popover.isShown && !self.popover.isDetached {
                self.closePopover(event)
            }
        }

        if UserPreferences.keyboardShortcutEnabled {
            registerHotkey()
        }
        
        updateTitle()
    }

    func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
        eventMonitor?.stop()
    }

    // MARK: - Public methods

    func registerHotkey() {
        guard let hotkeyCenter = DDHotKeyCenter.shared() else { return }

        let modifiers: UInt = NSEvent.ModifierFlags.control.rawValue | NSEvent.ModifierFlags.command.rawValue

        // Register system-wide summon hotkey
        hotkeyCenter.registerHotKey(withKeyCode: UInt16(kVK_ANSI_M),
                                    modifierFlags: modifiers,
                                    target: self,
                                    action: #selector(AppDelegate.hotkeyAction),
                                    object: nil)
    }

    func unregisterHotKey() {
        guard let hotkeyCenter = DDHotKeyCenter.shared() else { return }
        hotkeyCenter.unregisterAllHotKeys()
    }

    @objc func hotkeyAction() {
        let sb = NSStoryboard(name: NSStoryboard.Name(rawValue: "Hud"), bundle: nil)
        hudController = sb.instantiateInitialController() as? HudWindowController

        hudController!.setText(text: StatusItemBuilder(
            title: musicPlayerManager.currentPlayer?.currentTrack?.title,
            artist: musicPlayerManager.currentPlayer?.currentTrack?.artist,
            albumName: musicPlayerManager.currentPlayer?.currentTrack?.album,
            isPlaying: musicPlayerManager.currentPlayer?.playbackState == MusicPlaybackState.playing)
            .hideWhenPaused(v: false)
            .showTitle(v: true)
            .showAlbumName(v: true)
            .showArtist(v: true)
            .showPlayingIcon(v: true)
            .getString())

        hudController?.showWindow(nil)
        hudController?.window?.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
        if let t = removeHudTimer {
            t.invalidate()
        }
        removeHudTimer = Timer.scheduledTimer(
            timeInterval: 4,
            target: self,
            selector: #selector(AppDelegate.removeHud),
            userInfo: nil,
            repeats: false)
    }

    @objc func removeHud() {
        hudController = nil
    }

    @objc func updateTitle() {
         let statusItemTitle = StatusItemBuilder(
            title: musicPlayerManager.currentPlayer?.currentTrack?.title,
            artist: musicPlayerManager.currentPlayer?.currentTrack?.artist,
            albumName: musicPlayerManager.currentPlayer?.currentTrack?.album,
            isPlaying: musicPlayerManager.currentPlayer?.playbackState == MusicPlaybackState.playing)
            .hideWhenPaused(v: UserPreferences.hideTitleArtistWhenPaused)
            .showTitle(v: UserPreferences.showTitle)
            .showAlbumName(v: UserPreferences.showAlbumName)
            .showArtist(v: UserPreferences.showArtist)
            .showPlayingIcon(v: UserPreferences.showPlayingIcon)
            .getString()
            if lastStatusTitle != statusItemTitle {
                updateStatusTitle(newTitle: statusItemTitle)
            }
    }

    // MARK: - Popover methods

    @objc func openPrefs(_: NSMenuItem) {
        preferencesController = (NSStoryboard(name: NSStoryboard.Name(rawValue: "Preferences"), bundle: nil).instantiateInitialController() as! NSWindowController)
        preferencesController?.showWindow(self)
    }

    func openURL(url: URL?) {
        if let url = url, NSWorkspace.shared.open(url) {
            print("default browser was successfully opened")
        }
    }

    @objc func openKmikiy(_: NSMenuItem) {
        openURL(url: kmikiyURL)
    }

    @objc func openIssues(_: NSMenuItem) {
        openURL(url: issuesURL)
    }

    @objc func quit(_: NSMenuItem) {
        NSApp.terminate(self)
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        let event = NSApp.currentEvent!

        switch event.type {
        case NSEvent.EventType.rightMouseUp:
            if popover.isShown && !popover.isDetached {
                closePopover(sender)
            }
            statusItem.menu = menu
            statusItem.popUpMenu(menu)

            // This is critical, otherwise clicks won't be processed again
            statusItem.menu = nil
        default:
            if popover.isShown && !popover.isDetached {
                closePopover(sender)
            } else {
                // SpotifyAppleScript.startSpotify(hidden: true)
                showPopover(sender)
            }
        }
    }

    @objc func checkForUpdates(_: NSMenuItem) {
        SUUpdater.shared().checkForUpdates(nil)
    }

    public func updateStatusTitle(newTitle: String) {
        if newTitle != lastStatusTitle {
            menuBar.updateTitle(title: newTitle)
        }
        statusItem.title = newTitle
        lastStatusTitle = newTitle
        if let button = statusItem.button {
            button.image = chooseIcon(musicPlayerName: musicPlayerManager.currentPlayer?.name)
        }

        // Show the icon regardless of setting if char count == 0
        if statusItem.title?.count == 0 && statusItem.button != nil {
            if let button = statusItem.button {
                button.image = spotMenuIcon
            }
        }
    }

    // MARK: - Private methods

    private func chooseIcon(musicPlayerName: MusicPlayerName?) -> NSImage! {
        if !UserPreferences.showSpotMenuIcon {
            return nil
        }
        if musicPlayerName == MusicPlayerName.iTunes {
            return spotMenuIconItunes
        } else {
            return spotMenuIcon
        }
    }

    private func showPopover(_: AnyObject?) {
        popover.appearance = appearance()

        let rect = statusItem.button?.window?.convertToScreen((statusItem.button?.frame)!)
        let xOffset = UserPreferences.fixPopoverToTheRight ? ((hiddenController?.window?.contentView?.frame.midX)! - (statusItem.button?.frame.maxX)!) : ((hiddenController?.window?.contentView?.frame.midX)! - (statusItem.button?.frame.midX)!)
        let x = (rect?.origin.x)! - xOffset
        let y = (rect?.origin.y)! // - (hiddenController?.contentViewController?.view.frame.maxY)!
        hiddenController?.window?.setFrameOrigin(NSPoint(x: x, y: y))
        hiddenController?.showWindow(self)
        popover.show(relativeTo: (hiddenController?.window?.contentView?.bounds)!, of: (hiddenController?.window?.contentView)!, preferredEdge: NSRectEdge.minY)
        eventMonitor?.start()
    }

    private func closePopover(_ sender: AnyObject?) {
        hiddenController?.close()
        popover.performClose(sender)
        eventMonitor?.stop()
    }

    enum InterfaceStyle: String {
        case Dark, Light

        init() {
            let type = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
            self = InterfaceStyle(rawValue: type)!
        }
    }

    func appearance() -> NSAppearance? {
        switch InterfaceStyle() {
        case .Dark:
            return NSAppearance(named: .vibrantDark)
        case .Light:
            return NSAppearance(named: .vibrantLight)
        }
    }

    class PopOverDelegate: NSObject, NSPopoverDelegate {
        func popoverShouldDetach(_: NSPopover) -> Bool {
            return true
        }
    }
}

extension AppDelegate: MusicPlayerManagerDelegate {
    func manager(_: MusicPlayerManager, trackingPlayer _: MusicPlayer, didChangeTrack _: MusicTrack, atPosition _: TimeInterval) {
        updateTitle()
    }

    func manager(_: MusicPlayerManager, trackingPlayer _: MusicPlayer, playbackStateChanged _: MusicPlaybackState, atPosition _: TimeInterval) {
        updateTitle()
    }

    func manager(_: MusicPlayerManager, trackingPlayerDidQuit _: MusicPlayer) {
        updateTitle()
    }

    func manager(_: MusicPlayerManager, trackingPlayerDidChange player: MusicPlayer) {
        UserPreferences.lastMusicPlayer = player.name.rawValue
    }
}
