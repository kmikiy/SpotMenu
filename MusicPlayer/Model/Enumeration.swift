//
//  PlayerEnum.swift
//  MusicPlayer
//
//  Created by Michael Row on 2017/9/17.
//

import Foundation

public enum MusicPlaybackState {
    case stopped
    case playing
    case paused
    case fastForwarding
    case rewinding    
    case reposition
    
    var isActiveState: Bool {
        switch self {
        case .stopped, .paused:
            return false
        default:
            return true
        }
    }
}

public enum MusicRepeatMode {
    case none
    case one
    case all
}

public enum MusicShuffleMode {
    case songs
    case albums
    case groupings
}

public enum MusicPlayerName: String {
    case iTunes = "iTunes"
    case vox = "Vox"
    case spotify = "Spotify"
    
    var bundleID: String {
        switch self {
        case .iTunes:
            return "com.apple.iTunes"
        case .vox:
            return "com.coppertino.Vox"
        case .spotify:
            return "com.spotify.client"
        }
    }
}
