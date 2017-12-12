//
//  MusicPlayerEX.swift
//  MusicPlayer
//
//  Created by Michael Row on 2017/9/23.
//

import Foundation

protocol MusicPlayerEX: MusicPlayer, Hashable {
        
    /// The current track of the MusicPlayer remembered.
    var currentTrack: MusicTrack? { get set }
    
    /// The current track of the original player.
    var originalPlayerCurrentTrack: MusicTrack? { get }
    
    /// The track start time of the MusicPlayer remembered.
    var rememberedTrackStateDate: Date { get set }
    
    // MARK: Notification
    
    /// Observe the player info change event.
    func observePlayerInfoNotification()
    
    /// remove the player info change event.
    func removePlayerInfoNotification()
    
    /// Handle player info changed event.
    func playerInfoChanged(_ notification: Notification)
    
    // MARK: Observing
    
    /// Start the timer observing the player needed.
    func startPeriodTimerObserving()
    
    // - MARK: Check Event
    
    /// Check whether the player's track has changed or not.
    func musicTrackCheckEvent()
    
    /// Check whether the player is repositioning or not.
    func repositionCheckEvent()
    
    /// Handle the error that player is not active when reposition checking
    func repositionCheckingErrorHandle()
}

// Default implementations for superprotocol MusicPlayer
extension MusicPlayerEX {
    
    func startPlayerTracking() {
        // Initialize Tracking state.
        musicTrackCheckEvent()
        delegate?.player(self, playbackStateChanged: playbackState, atPosition: playerPosition)
        
        // start tracking.
        startPeriodTimerObserving()
        observePlayerInfoNotification()
    }
    
    func stopPlayerTracking() {
        currentTrack = nil
        PlayerTimer.shared.unregister(self)
        removePlayerInfoNotification()
    }
}

// Check Event
extension MusicPlayerEX {
    
    func musicTrackCheckEvent() {
        guard isRunning,
              let newTrack = originalPlayerCurrentTrack,
              currentTrack == nil || currentTrack! != newTrack
        else { return }
        currentTrack = newTrack
        delegate?.player(self, didChangeTrack: newTrack, atPosition: playerPosition)
    }
    
    func repositionCheckEvent() {
        // check playback state
        guard playbackState.isActiveState
        else {
            repositionCheckingErrorHandle()
            return
        }
        
        // check position
        let currentPosition = playerPosition
        let accurateStartDate = trackStartDate
        let deltaPosition = accurateStartDate.timeIntervalSince(rememberedTrackStateDate)
        
        guard deltaPosition <= -MusicPlayerConfig.Precision || deltaPosition >= MusicPlayerConfig.Precision else {
            rememberedTrackStateDate = accurateStartDate
            return
        }
        
        let currentState = playbackState
        if currentState == .fastForwarding || currentState == .rewinding {
            delegate?.player(self, playbackStateChanged: currentState, atPosition: currentPosition)
        } else {
            delegate?.player(self, playbackStateChanged: .reposition, atPosition: currentPosition)
        }
        rememberedTrackStateDate = accurateStartDate
    }
}

// Equatable
extension MusicPlayerEX {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
