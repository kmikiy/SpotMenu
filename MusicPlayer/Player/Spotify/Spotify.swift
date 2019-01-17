//
//  Spotify.swift
//  MusicPlayer
//
//  Created by Michael Row on 2017/8/31.
//

import Foundation
import ScriptingBridge

class Spotify {
    
    var spotifyPlayer: SpotifyApplication
    
    var currentTrack: MusicTrack?
    
    weak var delegate: MusicPlayerDelegate?
    
    var rememberedTrackStateDate = Date()
    
    fileprivate(set) var hashValue: Int
    
    required init?() {
        guard let player = SBApplication(bundleIdentifier: MusicPlayerName.spotify.bundleID) else { return nil }
        spotifyPlayer = player
        hashValue = Int(arc4random())
    }
    
    deinit {
        stopPlayerTracking()
    }
    
    // MARK: - Player Event Handle
    
    func pauseEvent() {
        PlayerTimer.shared.unregister(self)
        delegate?.player(self, playbackStateChanged: .paused, atPosition: playerPosition)
    }
    
    func stoppedEvent() {
        PlayerTimer.shared.unregister(self)
        delegate?.playerDidQuit(self)
    }
    
    func playingEvent() {
        musicTrackCheckEvent()
        delegate?.player(self, playbackStateChanged: .playing, atPosition: playerPosition)
        startPeriodTimerObserving()
    }
    
    // MARK: - Notification Events
    
    @objc func playerInfoChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let playerState = userInfo["Player State"] as? String
        else { return }
        
        switch playerState {
        case "Paused":
            pauseEvent()
        case "Stopped":
            stoppedEvent()
        case "Playing":
            playingEvent()
        default:
            break
        }
    }
    
    // MARK: - Timer Events
    
    func startPeriodTimerObserving() {
        // start timer
        let event = PlayerTimer.Event(kind: .Infinite, precision: MusicPlayerConfig.TimerInterval) { time in
            self.repositionCheckEvent()
        }
        PlayerTimer.shared.register(self, event: event)

        // write down the track start time
        rememberedTrackStateDate = trackStartDate
    }
}

// MARK: - Spotify Track

extension SpotifyTrack {
    
    var musicTrack: MusicTrack? {
        
        guard let id = id?(),
              let title = name,
              let duration = duration
        else { return nil }
        
        var url: URL? = nil
        if let spotifyUrl = spotifyUrl {
            url = URL(fileURLWithPath: spotifyUrl)
        }
        return MusicTrack(id: id, title: title, album: album, artist: artist, duration: TimeInterval(duration/1000), artwork: artwork, artworkUrl: artworkUrl, lyrics: nil, url: url, originalTrack: self as? SBObject)
    }
}
