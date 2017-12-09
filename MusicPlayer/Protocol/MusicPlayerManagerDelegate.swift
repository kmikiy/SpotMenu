//
//  MusicPlayerManagerDelegate.swift
//  MusicPlayer
//
//  Created by Michael Row on 2017/9/4.
//

import Foundation

public protocol MusicPlayerManagerDelegate: class {
    
    /// Tells the delegate the manager's tracking player has changed track.
    ///
    /// - Parameters:
    ///   - manager: The manager to handle all players.
    ///   - player: Current music player that manager is tracking to.
    ///   - track: The track the player change to.
    ///   - position: The player's current playing position.
    func manager(_ manager: MusicPlayerManager, trackingPlayer player: MusicPlayer, didChangeTrack track: MusicTrack, atPosition position: TimeInterval)
    
    
    /// Tells the delegate the playback state of the tracking player has been changed.
    ///
    /// - Parameters:
    ///   - manager: The manager to handle all players.
    ///   - player: Current music player that manager is tracking to.
    ///   - playbackState: The player's playback state.
    ///   - position: The player's current playing position.
    func manager(_ manager: MusicPlayerManager, trackingPlayer player: MusicPlayer, playbackStateChanged playbackState: MusicPlaybackState, atPosition position: TimeInterval)
    
    
    /// Tells the delegate the manager's tracking player has quitted.
    ///
    /// - Parameters:
    ///   - manager: The manager to handle all players.
    ///   - player: Current music player that manager is tracking to.
    func manager(_ manager: MusicPlayerManager, trackingPlayerDidQuit player: MusicPlayer)
    
    
    /// Tells the delegate the manager has changed its tracking player.
    ///
    /// - Parameters:
    ///   - manager: The manager to handle all players.
    ///   - player: Current music player that manager is tracking to.
    func manager(_ manager: MusicPlayerManager, trackingPlayerDidChange player: MusicPlayer)
    
}
