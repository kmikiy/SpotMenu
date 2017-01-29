//
//  AppDelegate.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 02/09/16.
//  Copyright © 2016 KM. All rights reserved.
//

import Cocoa
import Spotify

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    var eventMonitor: EventMonitor?

    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let popover = NSPopover()
    var timer: Timer?
    
    var lastTitle = ""
    var lastArtist = ""
    var lastState = PlayerState.playing
    
    var initialWidth:CGFloat = 0
    
    let url = URL(string: "https://github.com/kmikiy/SpotMenu")
    
    let menu = NSMenu()
    
    var hiddenView: NSView = NSView(frame: NSRect(x: 0, y: 0, width: 1, height: 1))
    

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.action = #selector(AppDelegate.togglePopover(_:))
            button.addSubview(hiddenView)
            updateTitle()
            initialWidth = statusItem.button!.bounds.width
            updateHidden()
        }
        
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(AppDelegate.quit(_:)), keyEquivalent: "Q"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Issues", action: #selector(AppDelegate.openSite(_:)), keyEquivalent: "I"))
        menu.addItem(NSMenuItem(title: " - kmikiy - ", action: #selector(AppDelegate.openSite(_:)), keyEquivalent: ""))
        
        popover.contentViewController = ViewController(nibName: "ViewController", bundle: nil)
        //popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [unowned self] event in
            if self.popover.isShown {
                self.closePopover(event)
            }
        }
        eventMonitor?.start()
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(AppDelegate.postUpdateNotification), userInfo: nil, repeats: true)
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.updateTitleAndPopover), name: NSNotification.Name(rawValue: InternalNotification.key), object: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        eventMonitor?.stop()
        NotificationCenter.default.removeObserver(self)
        timer!.invalidate()
    }

    
    func postUpdateNotification(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: InternalNotification.key), object: self)
    }
    
    func updateTitle(){
        let state = Spotify.playerState
        if let artist = Spotify.currentTrack.artist {
            if let title = Spotify.currentTrack.title , lastTitle != title || lastArtist != artist || lastState != state {
                switch state {
                case .playing:
                    statusItem.title = "🎶 \(artist) - \(title)  "
                default:
                    statusItem.title = "\(artist) - \(title)  "
                }
                
                lastArtist = artist
                lastTitle = title
                lastState = state
            }
        } else {
            statusItem.title = nil
        }
        
    }
    
    func updateHidden(){
        hiddenView.frame = NSRect(x: statusItem.button!.bounds.width-initialWidth/2, y: statusItem.button!.bounds.height-1, width: 1, height: 1)
        statusItem.button!.updateLayer()
    }
    
    func updateTitleAndPopover() {
        updateTitle()
        updateHidden()
    }
    

    // MARK: - Popover
    func openSite(_ sender: NSMenuItem) {
//        NSApplicationDelegate.open(url, options: [:], completionHandler: nil)
    }
    
    func quit(_ sender: NSMenuItem) {
       NSApp.terminate(self)
    }

    func showPopover(_ sender: AnyObject?) {
        initialWidth = statusItem.button!.bounds.width
        updateHidden()
        popover.show(relativeTo: hiddenView.bounds, of: hiddenView, preferredEdge: NSRectEdge.minY)
        eventMonitor?.start()
    }
    
    func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    func togglePopover(_ sender: AnyObject?) {
        let event = NSApp.currentEvent!
        
        if event.type == NSEventType.rightMouseUp {
            if popover.isShown{
                closePopover(sender)
            }
                
            statusItem.menu = menu
            statusItem.popUpMenu(menu)
            
            // This is critical, otherwise clicks won't be processed again
            statusItem.menu = nil
            
        } else {
            statusItem.menu = nil
            if popover.isShown {
                closePopover(sender)
            } else {
                popover.contentViewController = ViewController(nibName: "ViewController", bundle: nil)
                showPopover(sender)
            }
        }
    }
}

