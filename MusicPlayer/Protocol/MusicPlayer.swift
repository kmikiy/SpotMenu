//
//  MusicPlayer.swift
//  MusicPlayer
//
//  Created by Michael Row on 2017/9/17.
//

import Cocoa
import ScriptingBridge

struct MusicPlayerConfig {
    static let TimerInterval = 0.5
    static let Precision = 0.25
}

public protocol MusicPlayer: class {
    
    init?()
    weak var delegate: MusicPlayerDelegate? { get set }
    
    /// Player name of the MusicPlayer instance.
    var name: MusicPlayerName { get }
    /// The track the player is playing.
    var currentTrack: MusicTrack? { get }
    /// The playback state of the player.
    var playbackState: MusicPlaybackState { get }
    /// The repeate mode of the player.
    var repeatMode: MusicRepeatMode? { get set }
    /// The shuffle mode of the player.
    var shuffleMode: MusicShuffleMode? { get set }
    /// The player position of the player.
    var playerPosition: TimeInterval { get set }
    /// The original ScritingBridge player of the MusicPlayer instance.
    var originalPlayer: SBApplication { get }
    
    /// Make the player play.
    func play()
    /// Pause the player.
    func pause()
    /// Stop the player from playing.
    func stop()
    /// Play the next song if possibled.
    func playNext()
    /// Play the previous song if possibled.
    func playPrevious()
    
    /// Make the player start Tracking the external player.
    func startPlayerTracking()
    
    /// Make the player stop Tracking the external player.
    func stopPlayerTracking()
}

// Application Control
public extension MusicPlayer {
    
    /// Check whether the player is running.
    public var isRunning: Bool {
        return originalPlayer.isRunning
    }
    
    /// Activate the player from background or killed state.
    public func activate() {
        originalPlayer.activate()
    }
}

// Start Time
public extension MusicPlayer {
    
    /// The date of the current track started.
    public var trackStartDate: Date {
        return Date(timeIntervalSinceNow: -playerPosition)
    }
}
