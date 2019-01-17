//
//  MusicPlayerDelegate.swift
//  MusicPlayer
//
//  Created by Michael Row on 2017/9/2.
//

import Foundation

public protocol MusicPlayerDelegate: class {
    
    /// Tells the delegate the playing track has been changed.
    ///
    /// - Parameters:
    ///   - player: The player which triggers this event.
    ///   - track: The track which is played by the player.
    ///   - position: Player position.
    func player(_ player: MusicPlayer, didChangeTrack track: MusicTrack, atPosition position: TimeInterval)
    
    
    /// Tells the delegate the player's playback state has been changed.
    ///
    /// - Parameters:
    ///   - player: The player which triggers this event.
    ///   - position: Player position.
    func player(_ player: MusicPlayer, playbackStateChanged playbackState: MusicPlaybackState, atPosition postion: TimeInterval)
    
    
    /// Tells the delegate the player has quitted.
    ///
    /// - Parameter player: The player which triggers this event.
    func playerDidQuit(_ player: MusicPlayer)
}
