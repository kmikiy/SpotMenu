//
//  Spotify.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 02/09/16.
//  Copyright © 2016 KM. All rights reserved.
//

import Foundation

public class Spotify: NSObject {
    
    // MARK: - Variables
    public static var currentTrack = Track()
    
    public static var playerState: PlayerState {
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
                Spotify.executeAppleScriptWithString("pause")
            case .playing:
                Spotify.executeAppleScriptWithString("play")
            }
            NSNotificationCenter.defaultCenter().postNotificationName(InternalNotification.key, object: self)
        }
    }
    
    
    // MARK: - Methods
    public static func playNext(completionHandler: (()->())? = nil){
        Spotify.executeAppleScriptWithString("play (next track)")
        completionHandler?()
        NSNotificationCenter.defaultCenter().postNotificationName(InternalNotification.key, object: self)
        
    }
    
    public static func playPrevious(completionHandler: (() -> ())? = nil){
        Spotify.executeAppleScriptWithString("play (previous track)")
        completionHandler?()
        NSNotificationCenter.defaultCenter().postNotificationName(InternalNotification.key, object: self)
    }
    

    
    // MARK: - Helpers
    static func executeAppleScriptWithString(command: String) -> String? {
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