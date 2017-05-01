//
//  AppDelegate.swift
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
    let settingsPopover = NSPopover()
    var timer: Timer?
    
    var lastTitle = ""
    var lastArtist = ""
    var lastState = PlayerState.playing
    
    var initialWidth:CGFloat = 0
    
    let projectURL = URL(string: "https://github.com/FernandoX7/SpStreamer")
    
    let menu = NSMenu()
    
    var hiddenView: NSView = NSView(frame: NSRect(x: 0, y: 0, width: 1, height: 1))
    
    // Settings
    var isDarkThemeToggled = true
    var isArtistNameToggled = true
    var isSongNameToggled = true
    var isPlayPauseIconsToggled = true
    var isSpotIconToggled = true
    var isScrollingSongNameToggled = true
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        //        UserPreferences.clearAllSettings()
        readSettings()
        
        if let button = statusItem.button {
            button.image = NSImage(named: "no-image")
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.action = #selector(AppDelegate.togglePopover(_:))
            button.addSubview(hiddenView)
            updateTitle()
            initialWidth = statusItem.button!.bounds.width
            updateHidden()
        }
        
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(AppDelegate.quit(_:)), keyEquivalent: "Q"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Github Project", action: #selector(AppDelegate.openSite(_:)), keyEquivalent: "I"))
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(AppDelegate.openSettings(_:)), keyEquivalent: "O"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Empty", action: nil, keyEquivalent: ","))
        
        
        popover.contentViewController = ViewController(nibName: "ViewController", bundle: nil)
        settingsPopover.contentViewController = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        //        popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [unowned self] event in
            if self.popover.isShown {
                self.closePopover(event)
            }
            if self.settingsPopover.isShown {
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
        if var artist = Spotify.currentTrack.albumArtist {
            if var title = Spotify.currentTrack.title , lastTitle != title || lastArtist != artist || lastState != state {
                isArtistNameToggled = UserPreferences.readSetting(key: UserPreferences.artistName)
                isSongNameToggled = UserPreferences.readSetting(key: UserPreferences.songName)
                isPlayPauseIconsToggled = UserPreferences.readSetting(key: UserPreferences.playPauseIcons)
                isSpotIconToggled = UserPreferences.readSetting(key: UserPreferences.spotIcon)
                var playIcon = "❚❚ "
                var pauseIcon = "▶ "
                var connectArtistAndSong = " -"
                var spotIconName = "StatusBarButtonImage"
                
                // Make sure to show at least one thing on the statusbar at all times
                if (!isArtistNameToggled && !isSongNameToggled && !isPlayPauseIconsToggled && !isSpotIconToggled) {
                    UserPreferences.setSetting(key: UserPreferences.spotIcon, value: true)
                }
                
                if isArtistNameToggled {
                    if !isSongNameToggled {
                        connectArtistAndSong = ""
                    }
                    artist = artist + connectArtistAndSong
                } else {
                    
                    artist = ""
                }
                
                if isSongNameToggled {
                    title = title + "  "
                } else {
                    title = ""
                }
                
                if !isPlayPauseIconsToggled {
                    playIcon = ""
                    pauseIcon = ""
                } else {
                    playIcon = "❚❚  "
                    pauseIcon = "▶  "
                }
                
                if !isSpotIconToggled {
                    spotIconName = "no-image"
                } else {
                    spotIconName = "StatusBarButtonImage"
                }
                
                switch state {
                case .playing:
                    statusItem.button?.image = NSImage(named: spotIconName)
                    if (isSpotIconToggled && !isArtistNameToggled && !isSongNameToggled && !isPlayPauseIconsToggled) {
                        statusItem.title = nil
                    } else {
                        statusItem.title = "\(playIcon)\(artist) \(title)  "
                    }
                default:
                    if (isSpotIconToggled && !isArtistNameToggled && !isSongNameToggled && !isPlayPauseIconsToggled) {
                        statusItem.title = nil
                    } else {
                        statusItem.title = "\(pauseIcon)\(artist) \(title)  "
                    }
                    statusItem.button?.image = NSImage(named: spotIconName)
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
        if let url = projectURL, NSWorkspace.shared().open(url) {
            print("Default browser successfully opened and pointed to: \(url)")
        }
    }
    
    func openSettings(_ sender: NSMenuItem) {
        if let button = statusItem.button {
            updateHidden()
            settingsPopover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            eventMonitor?.start()
        }
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
        settingsPopover.performClose(sender)
        eventMonitor?.stop()
    }
    
    func togglePopover(_ sender: AnyObject?) {
        checkTheme()
        let event = NSApp.currentEvent!
        
        if event.type == NSEventType.rightMouseUp {
            if popover.isShown{
                closePopover(sender)
            }
            
            if settingsPopover.isShown{
                closePopover(sender)
            }
            
            statusItem.menu = menu
            statusItem.popUpMenu(menu)
            
            // This is critical, otherwise clicks won't be processed again
            statusItem.menu = nil
            
        } else {
            statusItem.menu = nil
            if settingsPopover.isShown{
                closePopover(sender)
            }
            if popover.isShown {
                closePopover(sender)
            } else {
                popover.contentViewController = ViewController(nibName: "PopOver", bundle: nil)
                Spotify.startSpotify(hidden: true)
                showPopover(sender)
            }
        }
    }
    
    func readSettings() {
        isDarkThemeToggled = UserPreferences.readSetting(key: UserPreferences.darkTheme)
        isArtistNameToggled = UserPreferences.readSetting(key: UserPreferences.artistName)
        isSongNameToggled = UserPreferences.readSetting(key: UserPreferences.songName)
        isPlayPauseIconsToggled = UserPreferences.readSetting(key: UserPreferences.playPauseIcons)
        isSpotIconToggled = UserPreferences.readSetting(key: UserPreferences.spotIcon)
        isScrollingSongNameToggled = UserPreferences.readSetting(key: UserPreferences.scrollingSongName)
        
        
        checkTheme()
    }
    
    func checkTheme() {
        isDarkThemeToggled = UserPreferences.readSetting(key: UserPreferences.darkTheme)
        if isDarkThemeToggled {
            toggleDarkTheme(isDark: true)
        } else {
            toggleDarkTheme(isDark: false)
        }
    }
    
    func toggleDarkTheme(isDark: Bool) {
        if isDark {
            popover.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
            settingsPopover.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
            UserPreferences.setSetting(key: UserPreferences.darkTheme, value: true)
        } else {
            popover.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
            settingsPopover.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
            UserPreferences.setSetting(key: UserPreferences.darkTheme, value: false)
        }
    }
    
    
    
}

