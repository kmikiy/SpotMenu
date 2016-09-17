//
//  Spotify.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 02/09/16.
//  Copyright © 2016 KM. All rights reserved.
//

import Foundation

open class Spotify: NSObject {
    
    // MARK: - Variables
    open static var currentTrack = Track()
    
    open static var playerState: PlayerState {
        get {
            if let state = Spotify.executeAppleScriptWithString("get player state") {
                //print(state)
                if let stateEnum = PlayerState(rawValue: state) {
                    return stateEnum
                }
            }
            return PlayerState.paused
        }
        
        set {
            switch newValue {
            case .paused:
                _ = Spotify.executeAppleScriptWithString("pause")
            case .playing:
                _ = Spotify.executeAppleScriptWithString("play")
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: InternalNotification.key), object: self)
        }
    }
    
    
    // MARK: - Methods
    open static func playNext(_ completionHandler: (()->())? = nil){
        _ = Spotify.executeAppleScriptWithString("play (next track)")
        completionHandler?()
        NotificationCenter.default.post(name: Notification.Name(rawValue: InternalNotification.key), object: self)
        
    }
    
    open static func playPrevious(_ completionHandler: (() -> ())? = nil){
        _ = Spotify.executeAppleScriptWithString("play (previous track)")
        completionHandler?()
        NotificationCenter.default.post(name: Notification.Name(rawValue: InternalNotification.key), object: self)
    }
    

    
    // MARK: - Helpers
    static func executeAppleScriptWithString(_ command: String) -> String? {
        let myAppleScript = "if application \"Spotify\" is running then tell application \"Spotify\" to \(command)"
        //print(myAppleScript)
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: myAppleScript) {
            if let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(
                &error) {
                return output.stringValue
            } else if (error != nil) {
                print("error: \(error)")
            }
        }
        return nil
    }
    
}
