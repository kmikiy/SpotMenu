//
//  iTunes+MusicPlayer.swift
//  MusicPlayer
//
//  Created by Michael Row on 2017/9/17.
//

import Foundation
import ScriptingBridge
import iTunesBridge

extension iTunes: MusicPlayer {
    
    var name: MusicPlayerName { return .iTunes }
    
    var playbackState: MusicPlaybackState {
        guard isRunning,
              let playerState = iTunesPlayer.playerState
        else { return .stopped }
        return MusicPlaybackState(playerState)
    }
    
    var repeatMode: MusicRepeatMode? {
        get {
            guard isRunning,
                  let songRepeat = iTunesPlayer.songRepeat
            else { return nil }
            return MusicRepeatMode(songRepeat)
        }
        set {
            guard isRunning,
                  let songRepeat = newValue?.iTunesERptValue
            else { return }
            iTunesPlayer.setSongRepeat?(songRepeat)
        }
    }
    
    var shuffleMode: MusicShuffleMode? {
        get {
            guard isRunning,
                  let shuffleMode = iTunesPlayer.shuffleMode
            else { return nil }
            return MusicShuffleMode(shuffleMode)
        }
        set {
            guard isRunning,
                  let shuffleMode = newValue?.iTunesEShMValue
            else { return }
            iTunesPlayer.setShuffleMode?(shuffleMode)
        }
    }
    
    var playerPosition: TimeInterval {
        get {
            guard isRunning,
                  let playerPosition = iTunesPlayer.playerPosition
            else { return 0 }
            return max(playerPosition, 0)
        }
        set {
            guard isRunning,
                  newValue >= 0
            else { return }
            iTunesPlayer.setPlayerPosition?(newValue)
        }
    }
    
    var originalPlayer: SBApplication {
        return iTunesPlayer as! SBApplication
    }
    
    func play() {
        guard isRunning,
              playbackState != .playing
        else { return }
        iTunesPlayer.playpause?()
    }
    
    func pause() {
        guard isRunning else { return }
        iTunesPlayer.pause?()
    }
    
    func stop() {
        guard isRunning else { return }
        iTunesPlayer.stop?()
    }
    
    func playNext() {
        guard isRunning else { return }
        iTunesPlayer.nextTrack?()
    }
    
    func playPrevious() {
        guard isRunning else { return }
        iTunesPlayer.previousTrack?()
    }
}

extension iTunes: MusicPlayerEX {
    
    var originalPlayerCurrentTrack: MusicTrack? {
        return iTunesPlayer.currentTrack?.musicTrack
    }
    
    func observePlayerInfoNotification() {
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(playerInfoChanged(_:)), name: NSNotification.Name.iTunesPlayerInfo, object: nil)
    }
    
    func removePlayerInfoNotification() {
        DistributedNotificationCenter.default().removeObserver(self)
    }
    
    func repositionCheckingErrorHandle() {
        PlayerTimer.shared.unregister(self)
    }
}

// MARK: - Enum Extension

fileprivate extension MusicPlaybackState {
    
    init(_ playbackState: iTunesEPlS) {
        switch playbackState {
        case .stopped:
            self = .stopped
        case .playing:
            self = .playing
        case .paused:
            self = .paused
        case .fastForwarding:
            self = .fastForwarding
        case .rewinding:
            self = .rewinding
        }
    }
}

fileprivate extension MusicRepeatMode {
    
    init(_ repeateMode: iTunesERpt) {
        switch repeateMode {
        case .off:
            self = .none
        case .one:
            self = .one
        case .all:
            self = .all
        }
    }
    
    var iTunesERptValue: iTunesERpt {
        switch self {
        case .none:
            return .off
        case .one:
            return .one
        case .all:
            return .all
        }
    }
}

fileprivate extension MusicShuffleMode {
    
    init(_ shuffleMode: iTunesEShM) {
        switch shuffleMode {
        case .songs:
            self = .songs
        case .albums:
            self = .albums
        case .groupings:
            self = .groupings
        }
    }
    
    var iTunesEShMValue: iTunesEShM {
        switch self {
        case .songs:
            return .songs
        case .albums:
            return .albums
        case .groupings:
            return .groupings
        }
    }
}
