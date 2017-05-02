//
//  UserPreferences.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 05. 01..
//  Copyright © 2017. KM. All rights reserved.
//

import Foundation

struct UserPreferences {
    
    private static let _showArtistConst = "showArtist"
    private static let _showTitleConst = "showTitle"
    private static let _showPlayingIconConst = "showPlayingIcon"
    private static let _showSpotMenuIconConst = "showSpotMenuIcon"
    private static let _fixPopoverToTheRightConst = "dropDownToTheRight"
    
    private static var _showArtist: Bool = false
    private static var _showTitle: Bool = false
    private static var _showPlayingIcon: Bool = false
    private static var _showSpotMenuIcon: Bool = false
    private static var _fixPopoverToTheRight: Bool = false
    
    private static func setSetting(key: String, value: Bool) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    private static func readSetting(key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    static func clearAllSettings() {
        print("clearing user settings")
        if let bundle = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundle)
        }
    }
    
    static func readPrefs(){
        _showArtist = UserPreferences.readSetting(key: _showArtistConst)
        _showTitle = UserPreferences.readSetting(key: _showTitleConst)
        _showPlayingIcon = UserPreferences.readSetting(key: _showPlayingIconConst)
        _showSpotMenuIcon = UserPreferences.readSetting(key: _showSpotMenuIconConst)
        _fixPopoverToTheRight = UserPreferences.readSetting(key: _fixPopoverToTheRightConst)
    }
    
    static var showArtist: Bool {
        get {
            return _showArtist
        }
        set {
            _showArtist = newValue
            UserPreferences.setSetting(key: _showArtistConst, value: newValue)
        }
    }
    
    static var showTitle: Bool {
        get {
            return _showTitle
        }
        set {
            _showTitle = newValue
            UserPreferences.setSetting(key: _showTitleConst, value: newValue)
        }
    }
    
    static var showPlayingIcon: Bool {
        get {
            return _showPlayingIcon
        }
        set {
            _showPlayingIcon = newValue
            UserPreferences.setSetting(key: _showPlayingIconConst, value: newValue)
        }
    }
    
    static var showSpotMenuIcon: Bool {
        get {
            return _showSpotMenuIcon
        }
        set {
            _showSpotMenuIcon = newValue
            UserPreferences.setSetting(key: _showSpotMenuIconConst, value: newValue)
        }
    }
    
    static var fixPopoverToTheRight: Bool {
        get {
            return _fixPopoverToTheRight
        }
        set {
            _fixPopoverToTheRight = newValue
            UserPreferences.setSetting(key: _fixPopoverToTheRightConst, value: newValue)
        }
    }
}

extension Bool {
    var asState: Int {
        let r = self ? 1:0
        return r
    }
}

extension Int {
    var asBool: Bool {return Bool(self as NSNumber)}
}
