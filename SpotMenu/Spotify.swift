//
//  Spotify.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 02/09/16.
//  Copyright © 2016 KM. All rights reserved.
//

import Foundation

class Spotify: NSObject {
    
    static var currentTrack = Track()
    static func playNext(completionHandler: (()->())? = nil){
        Spotify.executeAppleScriptWithString("play (next track)")
        completionHandler?()
        NSNotificationCenter.defaultCenter().postNotificationName(InternalNotification.key, object: self)
        
    }
    static func playPrevious(completionHandler: (() -> ())? = nil){
        Spotify.executeAppleScriptWithString("play (previous track)")
        completionHandler?()
        NSNotificationCenter.defaultCenter().postNotificationName(InternalNotification.key, object: self)
    }
    
    
    static private func executeAppleScriptWithString(command: String) -> String? {
        let myAppleScript = "if application \"Spotify\" is running then tell application \"Spotify\" to \(command)"
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
    
    class Track: NSObject {
        var title: String? {
            get { return Spotify.executeAppleScriptWithString("get name of current track") }
        }
        
        var artist: String? {
            get { return Spotify.executeAppleScriptWithString("get artist of current track") }
        }
        
        var artworkUrl: String? {
            get { return Spotify.executeAppleScriptWithString("get artwork url of current track") }
        }
        
        
    }
}