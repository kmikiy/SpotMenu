//
//  Spotify+MusicPlayer.swift
//  MusicPlayer
//
//  Created by Michael Row on 2017/9/17.
//

import Foundation
import ScriptingBridge

extension Spotify: MusicPlayer {
    
    var name: MusicPlayerName { return .spotify }
    
    var playbackState: MusicPlaybackState {
        guard isRunning,
              let playerState = spotifyPlayer.playerState
        else { return .stopped }
        return MusicPlaybackState(playerState)
    }
    
    var repeatMode: MusicRepeatMode? {
        get { return nil }
        set {}
    }
    
    var shuffleMode: MusicShuffleMode? {
        get { return nil }
        set {}
    }
    
    var playerPosition: TimeInterval {
        get {
            guard isRunning,
                  let playerPosition = spotifyPlayer.playerPosition
            else { return 0 }
            return max(playerPosition, 0)
        }
        set {
            guard isRunning,
                  newValue >= 0
            else { return }
            spotifyPlayer.setPlayerPosition?(newValue)
        }
    }
    
    func play() {
        guard isRunning else { return }
        spotifyPlayer.play?()
    }
    
    func pause() {
        guard isRunning else { return }
        spotifyPlayer.pause?()
    }
    
    func stop() {
        guard isRunning else { return }
        spotifyPlayer.pause?()
    }
    
    func playNext() {
        guard isRunning else { return }
        spotifyPlayer.nextTrack?()
    }
    
    func playPrevious() {
        guard isRunning else { return }
        spotifyPlayer.previousTrack?()
    }
    
    var originalPlayer: SBApplication {
        return spotifyPlayer as! SBApplication
    }
}

extension Spotify: MusicPlayerEX {
    
    var originalPlayerCurrentTrack: MusicTrack? {
        return spotifyPlayer.currentTrack?.musicTrack
    }
    
    func observePlayerInfoNotification() {
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(playerInfoChanged(_:)), name: NSNotification.Name.spotifyPlayerInfo, object: nil)
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
    
    init(_ playbackState: SpotifyEPlS) {
        switch playbackState {
        case .stopped:
            self = .stopped
        case .playing:
            self = .playing
        case .paused:
            self = .paused
        }
    }
}
