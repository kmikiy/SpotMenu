//
//  AppDelegate.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 02/09/16.
//  Copyright © 2016 KM. All rights reserved.
//

import Cocoa
import SnapKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    var eventMonitor: EventMonitor?

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    let popover = NSPopover()
    var timer: NSTimer?
    
    var lastTitle = ""
    var lastArtist = ""
    
    var initialWidth:CGFloat = 0

    var hiddenView: NSView = NSView(frame: NSRect(x: 0, y: 0, width: 1, height: 1))
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        if let button = statusItem.button {
            
            button.image = NSImage(named: "StatusBarButtonImage")
            button.action = #selector(AppDelegate.togglePopover(_:))
            button.addSubview(hiddenView)
            updateTitle()
            initialWidth = statusItem.button!.bounds.width
            updateHidden()
            
        }
        
        popover.contentViewController = ViewController(nibName: "ViewController", bundle: nil)
        //popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        
        eventMonitor = EventMonitor(mask: [.LeftMouseDownMask, .RightMouseDownMask]) { [unowned self] event in
            if self.popover.shown {
                self.closePopover(event)
            }
        }
        eventMonitor?.start()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(AppDelegate.postUpdateNotification), userInfo: nil, repeats: true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.updateTitleAndPopover), name: InternalNotification.key, object: nil)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        eventMonitor?.stop()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        timer!.invalidate()
    }

    
    func postUpdateNotification(){
        NSNotificationCenter.defaultCenter().postNotificationName(InternalNotification.key, object: self)
    }
    
    func updateTitle(){
        if let artist = Spotify.currentTrack.artist {
            if let title = Spotify.currentTrack.title where lastTitle != title || lastArtist != artist {
                statusItem.title = "\(artist) - \(title)  "
                lastArtist = artist
                lastTitle = title
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

    func showPopover(sender: AnyObject?) {
        initialWidth = statusItem.button!.bounds.width
        updateHidden()
        popover.showRelativeToRect(hiddenView.bounds, ofView: hiddenView, preferredEdge: NSRectEdge.MinY)
        eventMonitor?.start()
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    func togglePopover(sender: AnyObject?) {
        if popover.shown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
}

