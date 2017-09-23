//
//  UserPreferences.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 05. 01..
//  Copyright © 2017. KM. All rights reserved.
//

import Foundation

struct UserPreferences {
    
    // MARK: - Constant keys
    
    private struct Keys {
        static let showArtist = "showArtist"
        static let showTitle = "showTitle"
        static let showPlayIcon = "showPlayingIcon"
        static let showSpotMenuIcon = "showSpotMenuIcon"
        static let fixPopoverToRight = "dropDownToTheRight"
    }
    
    // MARK: - Properties
    
    static var showArtist: Bool {
        get {
            return UserPreferences.readSetting(key: Keys.showArtist)
        }
        set {
            UserPreferences.setSetting(key: Keys.showArtist, value: newValue)
        }
    }
    
    static var showTitle: Bool {
        get {
            return  UserPreferences.readSetting(key: Keys.showTitle)
        }
        set {
            UserPreferences.setSetting(key: Keys.showTitle, value: newValue)
        }
    }
    
    static var showPlayingIcon: Bool {
        get {
            return UserPreferences.readSetting(key: Keys.showPlayIcon)
        }
        set {
            UserPreferences.setSetting(key: Keys.showPlayIcon, value: newValue)
        }
    }
    
    static var showSpotMenuIcon: Bool {
        get {
            return UserPreferences.readSetting(key: Keys.showSpotMenuIcon)
        }
        set {
            UserPreferences.setSetting(key: Keys.showSpotMenuIcon, value: newValue)
        }
    }
    
    static var fixPopoverToTheRight: Bool {
        get {
            return UserPreferences.readSetting(key: Keys.fixPopoverToRight)
        }
        set {
            UserPreferences.setSetting(key: Keys.fixPopoverToRight, value: newValue)
        }
    }
    
    // MARK: - Public methods
    
    static func clearAllSettings() {
        print("clearing user settings")
        if let bundle = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundle)
        }
    }
    
    // MARK: - Private helper methods
    
    private static func setSetting(key: String, value: Bool) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    private static func readSetting(key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
}

extension Bool {
    var asState: Int {
        return self ? 1 : 0
    }
}

extension Int {
    var asBool: Bool {
        return Bool(self as NSNumber)
    }
}
