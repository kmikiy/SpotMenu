//
//  SettingsKeys.swift
//  SpStreamer
//
//  Created by Fernando Ramirez on 4/28/17.
//  Copyright © 2017 KM. All rights reserved.
//

import Foundation

struct UserPreferences {
    
    static let darkTheme = "darkTheme"
    static let artistName = "artistName"
    static let songName = "songName"
    static let playPauseIcons = "playPauseIcons"
    static let spotIcon = "spotIcon"
    static let scrollingSongName = "scrollingSongName"
    
    static func setSetting(key: String, value: Bool) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    static func readSetting(key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    static func clearAllSettings() {
        print("***CLEARING ALL USER SETTINGS***")
        if let bundle = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundle)
        }
    }
    
    struct other {
        static let appName = "SpStreamer"
        static let firstSettingsLaunch = "firstSettingsLaunch"
    }
    
}
