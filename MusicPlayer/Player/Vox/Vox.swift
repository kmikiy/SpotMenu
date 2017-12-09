//
//  Vox.swift
//  MusicPlayer
//
//  Created by Michael Row on 2017/8/31.
//

import Foundation
import ScriptingBridge

class Vox {
    
    weak var delegate: MusicPlayerDelegate?
    
    var voxPlayer: VoxApplication
    
    var currentTrack: MusicTrack?
    
    var rememberedTrackStateDate = Date()
    
    var currentPlaybackState = MusicPlaybackState.stopped
    
    fileprivate(set) var hashValue: Int
    
    required init?() {
        guard let player = SBApplication(bundleIdentifier: MusicPlayerName.vox.bundleID) else { return nil }
        voxPlayer = player
        hashValue = Int(arc4random())
        currentPlaybackState = playbackState
    }
    
    deinit {
        stopPlayerTracking()
    }
    
    // MARK: - Player Event Handle
    
    func playbackStateCheckEvent() {
        switch playbackState {
        case .stopped:
            stoppedEvent()
        case .paused:
            pauseEvent()
        case .playing:
            playingEvent()
        default:
            break
        }
    }
    
    func pauseEvent() {
        guard currentPlaybackState != .paused else { return }
        currentPlaybackState = .paused
        delegate?.player(self, playbackStateChanged: .paused, atPosition: playerPosition)
    }
    
    func stoppedEvent() {
        PlayerTimer.shared.unregister(self)
        guard currentPlaybackState != .stopped else { return }
        currentPlaybackState = .stopped
        delegate?.playerDidQuit(self)
    }
    
    func playingEvent() {
        let voxPosition = playerPosition
        
        if currentPlaybackState != .playing {
            currentPlaybackState = .playing
            delegate?.player(self, playbackStateChanged: .playing, atPosition: voxPosition)
        }
        
        repositionCheckEvent()
    }
    
    // MARK: - Notification Events
    
    @objc func playerInfoChanged(_ notification: Notification) {
        musicTrackCheckEvent()
        startPeriodTimerObserving()
    }
    
    // MARK: - Timer Events
    
    func startPeriodTimerObserving() {
        // start timer
        let event = PlayerTimer.Event(kind: .Infinite, precision: MusicPlayerConfig.TimerInterval) { time in
            self.playbackStateCheckEvent()
        }
        PlayerTimer.shared.register(self, event: event)

        // write down the track start time
        rememberedTrackStateDate = trackStartDate
    }
}
