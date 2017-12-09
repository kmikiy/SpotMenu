//
//  iTunes.swift
//  MusicPlayer
//
//  Created by Michael Row on 2017/8/31.
//

import Foundation
import ScriptingBridge
import iTunesBridge

class iTunes {
    
    var iTunesPlayer: iTunesApplication
    
    var currentTrack: MusicTrack?
    
    weak var delegate: MusicPlayerDelegate?
    
    var rememberedTrackStateDate = Date()
    
    fileprivate(set) var hashValue: Int
    
    required init?() {
        guard let player = SBApplication(bundleIdentifier: MusicPlayerName.iTunes.bundleID) else { return nil }
        iTunesPlayer = player
        hashValue = Int(arc4random())
    }
    
    deinit {
        stopPlayerTracking()
    }
    
    // MARK: - Player Event Handle
    
    func pauseEvent() {
        // Rewind and fast forward would send pause notification.
        guard playbackState == .paused else { return }
        delegate?.player(self, playbackStateChanged: .paused, atPosition: playerPosition)
        startRunningObserving()
    }
    
    func stoppedEvent() {
        delegate?.player(self, playbackStateChanged: .stopped, atPosition: playerPosition)
        startRunningObserving()
    }
    
    func playingEvent() {
        musicTrackCheckEvent()
        delegate?.player(self, playbackStateChanged: .playing, atPosition: playerPosition)
        startPeriodTimerObserving()
    }
    
    func runningCheckEvent() {
        if !isRunning {
            delegate?.playerDidQuit(self)
        }
    }
    
    // MARK: - Notification Event
    
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
        
        if let location = userInfo["Location"] as? String {
            currentTrack?.url = URL(fileURLWithPath: location)
        }
    }
    
    // MARK: - Timer Actions
    
    func startPeriodTimerObserving() {
        // start timer
        let event = PlayerTimer.Event(kind: .Infinite, precision: MusicPlayerConfig.TimerInterval) { time in
            self.repositionCheckEvent()
        }
        PlayerTimer.shared.register(self, event: event)
        
        // write down the track start time
        rememberedTrackStateDate = trackStartDate
    }
    
    func startRunningObserving() {
        // stop date
        let date = Date(timeIntervalSinceNow: 1.5)
        let event = PlayerTimer.Event(kind: .Period(date), precision: MusicPlayerConfig.TimerInterval) { time in
            self.runningCheckEvent()
        }
        PlayerTimer.shared.register(self, event: event)
    }
}

// MARK: - Track

extension iTunesTrack {
    
    var musicTrack: MusicTrack? {
        guard mediaKind == .music,
              let id = id?(),
              let name = name,
              let duration = duration
        else { return nil }
        
        var artwork: NSImage? = nil
        if let artworks = artworks?(),
           artworks.count > 0,
           let iTunesArtwork = artworks[0] as? iTunesArtwork
        {
            artwork = iTunesArtwork.data
        }
        
        return MusicTrack(id: String(id), title: name, album: album, artist: artist, duration: duration, artwork: artwork, lyrics: lyrics, url: nil, originalTrack: self as? SBObject)
    }
    
}
