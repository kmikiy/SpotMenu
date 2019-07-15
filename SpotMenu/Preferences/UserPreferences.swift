//
//  UserPreferences.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 05. 01..
//  Copyright © 2017. KM. All rights reserved.
//

import Foundation
import MusicPlayer

struct UserPreferences {

    // MARK: - Constant keys

    private struct Keys {

        static let showArtist = "showArtist"
        static let showTitle = "showTitle"
        static let showAlbumName = "showAlbumName"
        static let showPlayingIcon = "showPlayingIcon"
        static let showSpotMenuIcon = "showSpotMenuIcon"
        static let fixPopoverToTheRight = "dropDownToTheRight"
        static let hasBeenInitialized = "hasBeenInitialized"
        static let keyboardShortcutEnabled = "keyboardShortcutEnabled"
        static let hideTitleArtistWhenPaused = "hideTitleArtistWhenPaused"
        static let lastMusicPlayer = "lastMusicPlayer"
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
            return UserPreferences.readSetting(key: Keys.showTitle)
        }
        set {
            UserPreferences.setSetting(key: Keys.showTitle, value: newValue)
        }
    }

    static var showAlbumName: Bool {
        get {
            return UserPreferences.readSetting(key: Keys.showAlbumName)
        }
        set {
            UserPreferences.setSetting(key: Keys.showAlbumName, value: newValue)
        }
    }

    static var showPlayingIcon: Bool {
        get {
            return UserPreferences.readSetting(key: Keys.showPlayingIcon)
        }
        set {
            UserPreferences.setSetting(key: Keys.showPlayingIcon, value: newValue)
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
            return UserPreferences.readSetting(key: Keys.fixPopoverToTheRight)
        }
        set {
            UserPreferences.setSetting(key: Keys.fixPopoverToTheRight, value: newValue)
        }
    }

    static var keyboardShortcutEnabled: Bool {
        get {
            return UserPreferences.readSetting(key: Keys.keyboardShortcutEnabled)
        }
        set {
            UserPreferences.setSetting(key: Keys.keyboardShortcutEnabled, value: newValue)
        }
    }

    static var hideTitleArtistWhenPaused: Bool {
        get {
            return UserPreferences.readSetting(key: Keys.hideTitleArtistWhenPaused)
        }
        set {
            UserPreferences.setSetting(key: Keys.hideTitleArtistWhenPaused, value: newValue)
        }
    }

    static var lastMusicPlayer: String {
        get {
            if let val = UserPreferences.readSettingString(key: Keys.lastMusicPlayer) {
                return val
            }
            return MusicPlayerName.spotify.rawValue
        }
        set {
            UserPreferences.setSettingString(key: Keys.lastMusicPlayer, value: newValue)
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

    private static func setSettingString(key: String, value: String) {
        let ud = UserDefaults(suiteName: "group.KMikiy.SpotMenu")
        ud?.set(value, forKey: key)
        ud?.synchronize()
    }

    private static func readSetting(key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }

    private static func readSettingString(key: String) -> String? {
        let ud = UserDefaults(suiteName: "group.KMikiy.SpotMenu")
        return ud?.string(forKey: key)
    }

    // MARK: - Init / migrate

    static func initializeUserPreferences() {
        let hasBeenInitialized = UserPreferences.readSetting(key: Keys.hasBeenInitialized)
        guard !hasBeenInitialized else {
            return
        }

        // check if migration is needed

        if UserPreferences.showArtist ||
            UserPreferences.showTitle ||
            UserPreferences.showAlbumName ||
            UserPreferences.showPlayingIcon ||
            UserPreferences.showSpotMenuIcon ||
            UserPreferences.fixPopoverToTheRight ||
            UserPreferences.keyboardShortcutEnabled ||
            UserPreferences.hideTitleArtistWhenPaused {
            return
        }

        // set default settings

        UserPreferences.setSetting(key: Keys.hasBeenInitialized, value: true)
        UserPreferences.showArtist = true
        UserPreferences.showTitle = true
        UserPreferences.showAlbumName = true
        UserPreferences.showPlayingIcon = true
        UserPreferences.showSpotMenuIcon = true
        UserPreferences.keyboardShortcutEnabled = true
        UserPreferences.hideTitleArtistWhenPaused = true
    }
}

extension Bool {
    var asState: Int {
        return self ? 1 : 0
    }
}

extension Int {
    var asBool: Bool {
        return Bool(truncating: self as NSNumber)
    }
}

extension NSControl.StateValue {
    var asBool: Bool {
        return Bool(truncating: rawValue as NSNumber)
    }
}
