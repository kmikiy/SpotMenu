//
//  AppDelegate.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 02/09/16.
//  Copyright © 2016 KM. All rights reserved.
//

import Cocoa
import Spotify
import Carbon.HIToolbox
import Sparkle

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Properties

    private var hudController: NSWindowController?

    private var preferencesController: NSWindowController?
    
    private var popover: NSWindowController?
    
    private var eventMonitor: EventMonitor?

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    private var timer: Timer?
    
    private let issuesURL = URL(string: "https://github.com/kmikiy/SpotMenu/issues")
    
    private let kmikiyURL = URL(string: "https://github.com/kmikiy")
    
    private let menu = StatusMenu().menu
    
    private var hiddenView: NSView = NSView(frame: NSRect(x: 0, y: 0, width: 1, height: 1))
    
    private let spotMenuIcon = NSImage(named: NSImage.Name(rawValue: "StatusBarButtonImage"))
    
    private var lastStatusTitle: String = ""
    
    private var removeHudTimer: Timer?
    
    // MARK: - AppDelegate methods
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        UserPreferences.initializeUserPreferences()
       
        popover = (NSStoryboard(name: NSStoryboard.Name(rawValue: "PopoverWindow"), bundle: nil).instantiateInitialController() as! NSWindowController)
        popover?.contentViewController = PopOverViewController(nibName: NSNib.Name(rawValue: "PopOver"), bundle: nil)
        popover?.window?.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)))
        popover?.window?.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        
        if let button = statusItem.button {
            if UserPreferences.showSpotMenuIcon {
                button.image = spotMenuIcon
            }
            
            button.sendAction(on: [NSEvent.EventTypeMask.leftMouseUp, NSEvent.EventTypeMask.rightMouseUp])
            button.action = #selector(AppDelegate.togglePopover(_:))
            button.addSubview(hiddenView)
            updateTitle(newTitle: StatusItemBuilder()
                .showTitle(v: UserPreferences.showTitle)
                .showArtist(v: UserPreferences.showArtist)
                .showPlayingIcon(v: UserPreferences.showPlayingIcon)
                .getString())
        }
        
        eventMonitor = EventMonitor(mask: [NSEvent.EventTypeMask.leftMouseDown, NSEvent.EventTypeMask.rightMouseDown]) { [unowned self] event in
            self.closePopover(event)
        }
        
        timer = Timer.scheduledTimer(
            timeInterval: 1.5,
            target: self,
            selector: #selector(AppDelegate.postUpdateNotification),
            userInfo: nil,
            repeats: true)
        
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(AppDelegate.updateTitleAndPopover),
                name: NSNotification.Name(rawValue: InternalNotification.key),
                object: nil)
    
        if UserPreferences.keyboardShortcutEnabled {
            registerHotkey()
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        eventMonitor?.stop()
        NotificationCenter.default.removeObserver(self)
        timer!.invalidate()
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
        hudController = sb.instantiateInitialController() as? NSWindowController

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
        NotificationCenter.default.post(name: Notification.Name(rawValue: InternalNotification.key), object: self)
    }
    
    @objc func updateTitleAndPopover() {
        let statusItemTitle = StatusItemBuilder()
            .showTitle(v: UserPreferences.showTitle)
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
        
        if event.type == NSEvent.EventType.rightMouseUp {
            closePopover(sender)
            statusItem.menu = menu
            statusItem.popUpMenu(menu)
            
            // This is critical, otherwise clicks won't be processed again
            statusItem.menu = nil
        } else {
            statusItem.menu = nil
            Spotify.startSpotify(hidden: true)
            closePopover(sender)
            showPopover(nil)
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
        if (statusItem.title?.characters.count == 0 && statusItem.button != nil ){
            if let button = statusItem.button {
                button.image = spotMenuIcon
            }
        }
    }
    
    private func showPopover(_ sender: AnyObject?) {
        
        let rect = statusItem.button?.window?.convertToScreen((statusItem.button?.frame)!)

        let xOffset = UserPreferences.fixPopoverToTheRight ? ((popover?.contentViewController?.view.frame.maxX)!-(statusItem.button?.frame.maxX)!) : ((popover?.contentViewController?.view.frame.midX)! - (statusItem.button?.frame.midX)!)
        let x = (rect?.origin.x)! - xOffset
        let y = (rect?.origin.y)! - (popover?.contentViewController?.view.frame.maxY)!
        popover?.window?.setFrameOrigin(NSPoint(x:x , y:y))
        popover?.showWindow(self)
        
        eventMonitor?.start()
    }
    
    private func closePopover(_ sender: AnyObject?) {
        popover?.close()
        eventMonitor?.stop()
    }

}

