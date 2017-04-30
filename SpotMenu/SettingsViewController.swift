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
    @IBOutlet weak var alertMessageLabel: NSTextField!
    
    
    // Vars
    var isDarkThemeToggled = true
    var isArtistNameToggled = true
    var isSongNameToggled = true
    var isPlayPauseIconsToggled = true
    var isSpotIconToggled = true
    var isScrollingSongNameToggled = true
    var isFirstTimeLaunchingSettings = true
    
    let appDel = AppDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readSettings()
        firstTimeRunning()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        alertMessageLabel.isHidden = true
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
        print("[SettingsViewController - readSettings()] Reading settings")
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
        isDarkThemeToggled = UserPreferences.readSetting(key: UserPreferences.darkTheme)
        if !isDarkThemeToggled {
            UserPreferences.setSetting(key: UserPreferences.darkTheme, value: true)
            appDel.toggleDarkTheme(isDark: true)
        } else {
            UserPreferences.setSetting(key: UserPreferences.darkTheme, value: false)
            appDel.toggleDarkTheme(isDark: false)
        }
        alertMessageLabel.isHidden = false
        alertMessageLabel.stringValue = "Theme change will occurr as soon as you click outside the app"
    }
    
    @IBAction func toggleArtistName(_ sender: Any) {
        isArtistNameToggled = UserPreferences.readSetting(key: UserPreferences.artistName)
        if !isArtistNameToggled {
            UserPreferences.setSetting(key: UserPreferences.artistName, value: true)
            alertMessageLabel.stringValue = "Will display artist name as soon as you click outside the app"
        } else {
            UserPreferences.setSetting(key: UserPreferences.artistName, value: false)
            alertMessageLabel.stringValue = "Will hide artist name as soon as you click outside the app"
        }
        alertMessageLabel.isHidden = false
    }
    
    @IBAction func toggleSongName(_ sender: Any) {
        isSongNameToggled = UserPreferences.readSetting(key: UserPreferences.songName)
        if !isSongNameToggled {
            UserPreferences.setSetting(key: UserPreferences.songName, value: true)
            alertMessageLabel.stringValue = "Will display song name as soon as you click outside the app"
        } else {
            UserPreferences.setSetting(key: UserPreferences.songName, value: false)
            alertMessageLabel.stringValue = "Will hide song name as soon as you click outside the app"
        }
        alertMessageLabel.isHidden = false
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
