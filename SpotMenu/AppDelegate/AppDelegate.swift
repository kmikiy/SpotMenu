//
//  AppDelegate.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 02/09/16.
//  Copyright © 2016 KM. All rights reserved.
//

import Cocoa
import Carbon.HIToolbox
import Sparkle
import AppKit.NSAppearance
import MusicPlayer

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Properties

    private var hudController: HudWindowController?

    private var preferencesController: NSWindowController?
    
    private var hiddenController: NSWindowController?
    
    private let popover = NSPopover()
    
   // private let popoverDelegate = PopOverDelegate()
    
    private var eventMonitor: EventMonitor?

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    private let issuesURL = URL(string: "https://github.com/kmikiy/SpotMenu/issues")
    
    private let kmikiyURL = URL(string: "https://github.com/kmikiy")
    
    private let menu = StatusMenu().menu
    
    private let spotMenuIcon = NSImage(named: NSImage.Name(rawValue: "StatusBarButtonImage"))
    
    private var lastStatusTitle: String = ""
    
    private var removeHudTimer: Timer?
    
    private var musicPlayerManager: MusicPlayerManager!
    
    private var musicPlayerManager1: MusicPlayerManager!
    
    // MARK: - AppDelegate methods
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        UserPreferences.initializeUserPreferences()
        
        musicPlayerManager = MusicPlayerManager()
        musicPlayerManager.add(musicPlayer: .spotify)
        musicPlayerManager.add(musicPlayer: .iTunes)
        musicPlayerManager.delegate = self
        
        musicPlayerManager1 = MusicPlayerManager()
        musicPlayerManager1.add(musicPlayer: .spotify)
        musicPlayerManager1.add(musicPlayer: .iTunes)
        
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
            if UserPreferences.showSpotMenuIcon {
                button.image = spotMenuIcon
            }
            
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
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
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
        let sb = NSStoryboard.init(name: NSStoryboard.Name(rawValue: "Hud"), bundle: nil)
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
    
    @objc func postUpdateNotification(){
       // NotificationCenter.default.post(name: Notification.Name(rawValue: InternalNotification.key), object: self)
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
            updateTitle(newTitle: statusItemTitle)
        }
    }

    // MARK: - Popover methods
    
    @objc func openPrefs(_ sender: NSMenuItem) {
        preferencesController = (NSStoryboard(name: NSStoryboard.Name(rawValue: "Preferences"), bundle: nil).instantiateInitialController() as! NSWindowController)
        preferencesController?.showWindow(self)
    }
    
    func openURL(url :URL?) {
        if let url = url, NSWorkspace.shared.open(url) {
            print("default browser was successfully opened")
        }
    }
    
    @objc func openKmikiy(_ sender: NSMenuItem) {
        openURL(url: kmikiyURL)
    }
    
    @objc func openIssues(_ sender: NSMenuItem) {
        openURL(url: issuesURL)
    }
    
    @objc func quit(_ sender: NSMenuItem) {
       NSApp.terminate(self)
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        let event = NSApp.currentEvent!
        
        switch event.type {
        case NSEvent.EventType.rightMouseUp:
            if popover.isShown && !self.popover.isDetached {
                closePopover(sender)
            }
            statusItem.menu = menu
            statusItem.popUpMenu(menu)
            
            // This is critical, otherwise clicks won't be processed again
            statusItem.menu = nil
        default:
            if popover.isShown && !self.popover.isDetached {
                closePopover(sender)
            } else {
                //SpotifyAppleScript.startSpotify(hidden: true)
                showPopover(sender)
            }
        }
    }
    
    @objc func checkForUpdates(_ sender: NSMenuItem) {
        SUUpdater.shared().checkForUpdates(nil)
    }
    
    // MARK: - Private methods
    
    private func updateTitle(newTitle: String){
        statusItem.title = newTitle
        lastStatusTitle = newTitle
        if let button = statusItem.button {
            if UserPreferences.showSpotMenuIcon {
                button.image = spotMenuIcon
            } else {
                button.image = nil
            }
        }
        
        //Show the icon regardless of setting if char count == 0
        if (statusItem.title?.count == 0 && statusItem.button != nil ){
            if let button = statusItem.button {
                button.image = spotMenuIcon
            }
        }
    }
    
    
    private func showPopover(_ sender: AnyObject?) {
        popover.appearance = appearance()
        
        let rect = statusItem.button?.window?.convertToScreen((statusItem.button?.frame)!)
        let xOffset = UserPreferences.fixPopoverToTheRight ? ((hiddenController?.window?.contentView?.frame.midX)!-(statusItem.button?.frame.maxX)!) : ((hiddenController?.window?.contentView?.frame.midX)! - (statusItem.button?.frame.midX)!)
        let x = (rect?.origin.x)! - xOffset
        let y = (rect?.origin.y)! //- (hiddenController?.contentViewController?.view.frame.maxY)!
        hiddenController?.window?.setFrameOrigin(NSPoint(x:x , y:y))
        hiddenController?.showWindow(self)
        popover.show(relativeTo: (hiddenController?.window?.contentView?.bounds)!, of: (hiddenController?.window?.contentView)!, preferredEdge: NSRectEdge.minY)
        eventMonitor?.start()
    }
    
    private func closePopover(_ sender: AnyObject?) {
        hiddenController?.close()
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    enum InterfaceStyle : String {
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
        func popoverShouldDetach(_ popover: NSPopover) -> Bool {
            return true
        }
    }
}

extension AppDelegate: MusicPlayerManagerDelegate {
    func manager(_ manager: MusicPlayerManager, trackingPlayer player: MusicPlayer, didChangeTrack track: MusicTrack, atPosition position: TimeInterval) {
        updateTitle()
    }
    
    func manager(_ manager: MusicPlayerManager, trackingPlayer player: MusicPlayer, playbackStateChanged playbackState: MusicPlaybackState, atPosition position: TimeInterval) {
        updateTitle()
    }
    
    func manager(_ manager: MusicPlayerManager, trackingPlayerDidQuit player: MusicPlayer) {
        updateTitle()
    }
    
    func manager(_ manager: MusicPlayerManager, trackingPlayerDidChange player: MusicPlayer) {
   }
}
