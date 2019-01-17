//
//  Vox+MusicPlayer.swift
//  MusicPlayer
//
//  Created by Michael Row on 2017/9/17.
//

import Foundation
import ScriptingBridge

extension Vox: MusicPlayer {
    
    var name: MusicPlayerName { return .vox }
    
    var playbackState: MusicPlaybackState {
        guard isRunning,
              let playerState = voxPlayer.playerState
        else { return .stopped }
        return MusicPlaybackState(playerState)
    }
    
    var repeatMode: MusicRepeatMode? {
        get {
            guard isRunning,
                  let repeateState = voxPlayer.repeatState
            else { return nil }
            return MusicRepeatMode(repeateState)
        }
        set {
            guard isRunning,
                  let repeateState = newValue?.intValue
            else { return }
            voxPlayer.setRepeatState?(repeateState)
        }
    }
    
    var shuffleMode: MusicShuffleMode? {
        get { return nil }
        set {}
    }
    
    var playerPosition: TimeInterval {
        get {
            guard isRunning,
                  let currentTime = voxPlayer.currentTime
            else { return 0 }
            return currentTime
        }
        set {
            guard isRunning,
                  newValue >= 0
            else { return }
            voxPlayer.setCurrentTime?(newValue)
        }
    }
    
    func play() {
        guard isRunning else { return }
        voxPlayer.play?()
    }
    
    func pause() {
        guard isRunning else { return }
        voxPlayer.pause?()
    }
    
    func stop() {
        guard isRunning else { return }
        voxPlayer.pause?()
    }
    
    func playNext() {
        guard isRunning else { return }
        voxPlayer.next?()
    }
    
    func playPrevious() {
        guard isRunning else { return }
        voxPlayer.previous?()
    }
    
    var originalPlayer: SBApplication {
        return voxPlayer as! SBApplication
    }
}

extension Vox: MusicPlayerEX {
    
    var originalPlayerCurrentTrack: MusicTrack? {
        return voxPlayer.musicTrack
    }
    
    func observePlayerInfoNotification() {
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(playerInfoChanged(_:)), name: NSNotification.Name.voxTrackChanged, object: nil)
    }
    
    func removePlayerInfoNotification() {
        DistributedNotificationCenter.default().removeObserver(self)
    }
    
    func repositionCheckingErrorHandle() {}
    
}

// MARK: - Enum Extension

fileprivate extension MusicPlaybackState {
    
    init(_ playbackState: Int) {
        switch playbackState {
        case 0:
            self = .paused
        case 1:
            self = .playing
        default:
            self = .stopped
        }
    }
}

fileprivate extension MusicRepeatMode {
    
    init?(_ repeatMode: Int) {
        switch repeatMode {
        case 0:
            self = .none
        case 1:
            self = .one
        case 2:
            self = .all
        default:
            return nil
        }
    }
    
    var intValue: Int {
        switch self {
        case .none:
            return 0
        case .one:
            return 1
        case .all:
            return 2
        }
    }
}

// MARK: - VoxApplication

extension VoxApplication {
    
    var musicTrack: MusicTrack? {
        guard (self as! SBApplication).isRunning,
            let id = uniqueID,
            let title = track,
            let totalTime = totalTime
            else { return nil }
        var url: URL? = nil
        if let trackURL = trackUrl {
            url = URL(fileURLWithPath: trackURL)
        }
        return MusicTrack(id: id, title: title, album: album, artist: artist, duration: totalTime, artwork: artworkImage, artworkUrl: nil, lyrics: nil, url: url, originalTrack: nil)
    }
}
