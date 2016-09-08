//
//  CurrentTrack.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 06/09/16.
//  Copyright © 2016 KM. All rights reserved.
//

import Foundation

public class Track: NSObject {
    public var title: String? {
        get { return Spotify.executeAppleScriptWithString("get name of current track") }
    }
    
    public var artist: String? {
        get { return Spotify.executeAppleScriptWithString("get artist of current track") }
    }
    
    public var artworkUrl: String? {
        get { return Spotify.executeAppleScriptWithString("get artwork url of current track") }
    }
    
    public var positionPercentage: Double {
        get {
            let d = duration
            if d == 0.0 { return 0}
            return position/d
        }
        set {
            let d = duration
            if d == 0.0 { return }
            Spotify.executeAppleScriptWithString("set player position to \(d * newValue)")
            return
        }
        
    }
    
    public var position: Double {
        get {
            if let pos = Spotify.executeAppleScriptWithString("get player position") {
                if let val = Double(pos) {
                    return val
                }
            }
            return 0
        }
    }
    
    public var duration: Double {
        get {
            if let pos = Spotify.executeAppleScriptWithString("get duration of current track") {
                if let val = Double(pos) {
                    return val/1000
                }
            }
            return 0
        }
    }
}
