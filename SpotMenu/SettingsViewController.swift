//
//  SettingsViewController.swift
//  SpStreamer
//
//  Created by Fernando Ramirez on 4/28/17.
//  Copyright © 2017 Fernando Ramirez. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
    
    // Views
    @IBOutlet weak var darkThemeCB: NSButton!
    @IBOutlet weak var artistNameCB: NSButton!
    @IBOutlet weak var songNameCB: NSButton!
    @IBOutlet weak var playPauseCB: NSButton!
    @IBOutlet weak var spotIconCB: NSButton!
    @IBOutlet weak var scrollingSongNameCB: NSButton!
    
    // Vars
    var isDarkThemeToggled = true
    var isArtistNameToggled = true
    var isSongNameToggled = true
    var isPlayPauseIconsToggled = true
    var isSpotIconToggled = true
    var isScrollingSongNameToggled = true
    
    var isFirstTimeLaunchingSettings = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readSettings()
        firstTimeRunning()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        readSettings()
        initCheckboxStates()
    }
    
    func firstTimeRunning() {
        // First time will actually return false
        // as that's the default value for UserDefaults
        if !isFirstTimeLaunchingSettings {
            print("User has launched settings for the first time")
            UserPreferences.setSetting(key: UserPreferences.darkTheme, value: true)
            UserPreferences.setSetting(key: UserPreferences.artistName, value: true)
            UserPreferences.setSetting(key: UserPreferences.songName, value: true)
            UserPreferences.setSetting(key: UserPreferences.playPauseIcons, value: true)
            UserPreferences.setSetting(key: UserPreferences.spotIcon, value: true)
            UserPreferences.setSetting(key: UserPreferences.scrollingSongName, value: true)
            // no mo first time
            UserPreferences.setSetting(key: UserPreferences.other.firstSettingsLaunch, value: true)
        }
    }
    
    func readSettings() {
        print(UserPreferences.readSetting(key: UserPreferences.darkTheme))
        print(UserPreferences.readSetting(key: UserPreferences.artistName))
        print(UserPreferences.readSetting(key: UserPreferences.songName))
        print(UserPreferences.readSetting(key: UserPreferences.playPauseIcons))
        print(UserPreferences.readSetting(key: UserPreferences.spotIcon))
        print(UserPreferences.readSetting(key: UserPreferences.scrollingSongName))
        
        isDarkThemeToggled = UserPreferences.readSetting(key: UserPreferences.darkTheme)
        isArtistNameToggled = UserPreferences.readSetting(key: UserPreferences.artistName)
        isSongNameToggled = UserPreferences.readSetting(key: UserPreferences.songName)
        isPlayPauseIconsToggled = UserPreferences.readSetting(key: UserPreferences.playPauseIcons)
        isSpotIconToggled = UserPreferences.readSetting(key: UserPreferences.spotIcon)
        isScrollingSongNameToggled = UserPreferences.readSetting(key: UserPreferences.scrollingSongName)
        isFirstTimeLaunchingSettings = UserPreferences.readSetting(key: UserPreferences.other.firstSettingsLaunch)
        
        
    }
    
    func initCheckboxStates() {
        if isDarkThemeToggled {
            darkThemeCB.state = 1
        } else {
            darkThemeCB.state = 0
        }
        
        if isArtistNameToggled {
            artistNameCB.state = 1
        } else {
            artistNameCB.state = 0
        }
        
        if isSongNameToggled {
            songNameCB.state = 1
        } else {
            songNameCB.state = 0
        }
        
        if isPlayPauseIconsToggled {
            playPauseCB.state = 1
        } else {
            playPauseCB.state = 0
        }
        
        if isSpotIconToggled {
            spotIconCB.state = 1
        } else {
            spotIconCB.state = 0
        }
        
        if isScrollingSongNameToggled {
            scrollingSongNameCB.state = 1
        } else {
            scrollingSongNameCB.state = 0
        }
    }
    
    // Checked state = 1
    // Not checked state = 0
    @IBAction func toggleDarkTheme(_ sender: Any) {
        if !isDarkThemeToggled {
            UserPreferences.setSetting(key: UserPreferences.darkTheme, value: true)
        } else {
            UserPreferences.setSetting(key: UserPreferences.darkTheme, value: false)
        }
    }
    
    @IBAction func toggleArtistName(_ sender: Any) {
        if !isArtistNameToggled {
            UserPreferences.setSetting(key: UserPreferences.artistName, value: true)
        } else {
            UserPreferences.setSetting(key: UserPreferences.artistName, value: false)
        }
    }
    
    @IBAction func toggleSongName(_ sender: Any) {
        if !isSongNameToggled {
            UserPreferences.setSetting(key: UserPreferences.songName, value: true)
        } else {
            UserPreferences.setSetting(key: UserPreferences.songName, value: false)
        }
    }
    
    @IBAction func togglePlayPauseIcons(_ sender: Any) {
        if !isPlayPauseIconsToggled {
            UserPreferences.setSetting(key: UserPreferences.playPauseIcons, value: true)
        } else {
            UserPreferences.setSetting(key: UserPreferences.playPauseIcons, value: false)
        }
    }
    
    @IBAction func toggleSpotIcon(_ sender: Any) {
        if !isSpotIconToggled {
            UserPreferences.setSetting(key: UserPreferences.spotIcon, value: true)
        } else {
            UserPreferences.setSetting(key: UserPreferences.spotIcon, value: false)
        }
    }
    
    @IBAction func toggleScrollingSongName(_ sender: Any) {
        if !isScrollingSongNameToggled {
            UserPreferences.setSetting(key: UserPreferences.scrollingSongName, value: true)
        } else {
            UserPreferences.setSetting(key: UserPreferences.scrollingSongName, value: false)
        }
    }
    
    
    
    
    
    
}
