//
//  MusicTrack.swift
//  MusicPlayer
//
//  Created by Michael Row on 2017/9/17.
//

import Cocoa
import ScriptingBridge

public struct MusicTrack {
    
    public private(set) var id: String
    public private(set) var title: String
    public private(set) var album: String?
    public private(set) var artist: String?
    public private(set) var duration: TimeInterval
    public var artwork: NSImage?
    public var lyrics: String?
    public var url: URL?
    
    public private(set) var originalTrack: SBObject?
}

extension MusicTrack: Equatable {
    public static func ==(lhs: MusicTrack, rhs: MusicTrack) -> Bool {
        return lhs.id == rhs.id
    }
}
