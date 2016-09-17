//
//  CurrentTrack.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 06/09/16.
//  Copyright © 2016 KM. All rights reserved.
//

import Foundation

open class Track: NSObject {
    open var title: String? {
        get { return Spotify.executeAppleScriptWithString("get name of current track") }
    }
    
    open var artist: String? {
        get { return Spotify.executeAppleScriptWithString("get artist of current track") }
    }
    
    open var artworkUrl: String? {
        get { return Spotify.executeAppleScriptWithString("get artwork url of current track") }
    }
    
    open var positionPercentage: Double {
        get {
            let d = duration
            if d == 0.0 { return 0}
            return position/d
        }
        set {
            let d = duration
            if d == 0.0 { return }
            _ = Spotify.executeAppleScriptWithString("set player position to \(d * newValue)")
            return
        }
        
    }
    
    open var position: Double {
        get {
            if let pos = Spotify.executeAppleScriptWithString("get player position") {
                if let val = Double(pos) {
                    return val
                }
            }
            return 0
        }
    }
    
    open var duration: Double {
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
