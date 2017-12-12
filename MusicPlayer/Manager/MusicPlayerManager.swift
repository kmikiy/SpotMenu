//
//  MusicPlayerManager.swift
//  MusicPlayer
//
//  Created by Michael Row on 2017/9/3.
//

import Foundation

public class MusicPlayerManager {
    
    public weak var delegate: MusicPlayerManagerDelegate?
    
    public fileprivate(set) var musicPlayers = [MusicPlayer]()
    
    public fileprivate(set) weak var currentPlayer: MusicPlayer?
    
    public init() {}
}

// MARK: - Public Manager Methods

public extension MusicPlayerManager {
    
    /// The player names that added to the manager.
    public var allPlayerNames: [MusicPlayerName] {
        var playerNames = [MusicPlayerName]()
        for player in musicPlayers {
            playerNames.append(player.name)
        }
        return playerNames
    }
    
    /// Return the player with selected name if exists.
    public func existMusicPlayer(with name: MusicPlayerName) -> MusicPlayer? {
        for player in musicPlayers {
            if player.name == name {
                return player
            }
        }
        return nil
    }
    
    /// Add a music player to the manager.
    ///
    /// - Parameter name: The name of the music player you wanna add.
    public func add(musicPlayer name: MusicPlayerName) {
        for player in musicPlayers {
            guard player.name != name else { return }
        }
        guard let player = MusicPlayerFactory.musicPlayer(name: name) else { return }
        player.delegate = self
        player.startPlayerTracking()
        musicPlayers.append(player)
        
        selectMusicPlayer(with: player)
    }
    
    /// Add music players to the manager.
    ///
    /// - Parameter names: The names of the music player you wanna add.
    public func add(musicPlayers names: [MusicPlayerName]) {
        for name in names {
            add(musicPlayer: name)
        }
    }
    
    /// Remove a music player from the manager.
    ///
    /// - Parameter name: The name of the music player you wanna remove.
    public func remove(musicPlayer name: MusicPlayerName) {
        for index in 0 ..< musicPlayers.count {
            let player = musicPlayers[index]
            guard player.name == name else { continue }
            player.stopPlayerTracking()
            musicPlayers.remove(at: index)

            // if the removal is the current player, we should select a new one.
            if currentPlayer?.name == player.name {
                currentPlayer = nil
                selectMusicPlayerFromList()
            }
            return
        }
    }
    
    /// Remove music players from the manager.
    ///
    /// - Parameter names: The names of the music player you wanna remove.
    public func remove(musicPlayers names: [MusicPlayerName]) {
        for name in names {
            remove(musicPlayer: name)
        }
    }
    
    /// Remove all music players from the manager.
    public func removeAllMusicPlayers() {
        for player in musicPlayers {
            player.stopPlayerTracking()
        }
        musicPlayers.removeAll()
        currentPlayer = nil
    }
}

// MARK: - MusicPlayerDelegate

extension MusicPlayerManager: MusicPlayerDelegate {
    
    public func player(_ player: MusicPlayer, didChangeTrack track: MusicTrack, atPosition position: TimeInterval) {
        selectMusicPlayer(with: player)
        guard currentPlayer?.name == player.name else { return }
        delegate?.manager(self, trackingPlayer: player, didChangeTrack: track, atPosition: position)
    }
    
    public func player(_ player: MusicPlayer, playbackStateChanged playbackState: MusicPlaybackState, atPosition postion: TimeInterval) {
        selectMusicPlayer(with: player)
        guard currentPlayer?.name == player.name else { return }
        delegate?.manager(self, trackingPlayer: player, playbackStateChanged: playbackState, atPosition: postion)
        
        if !playbackState.isActiveState {
            selectMusicPlayerFromList()
        }
    }
    
    public func playerDidQuit(_ player: MusicPlayer) {
        guard currentPlayer != nil,
              currentPlayer!.name == player.name
        else { return }
        currentPlayer = nil
        delegate?.manager(self, trackingPlayerDidQuit: player)
        selectMusicPlayerFromList()
    }
    
    fileprivate func selectMusicPlayerFromList() {
        for player in musicPlayers {
            selectMusicPlayer(with: player)
            
            if let playerState = currentPlayer?.playbackState,
               playerState.isActiveState {
                return
            }
        }
    }
    
    fileprivate func selectMusicPlayer(with player: MusicPlayer) {
        guard shouldChangePlayer(with: player) else { return }
        currentPlayer = player
        delegate?.manager(self, trackingPlayerDidChange: player)
    }
    
    fileprivate func shouldChangePlayer(with player: MusicPlayer) -> Bool {
        // check wheter the new player and current one are the same player.
        guard currentPlayer !== player else { return false }
        // check the new player's playback state
        guard player.playbackState.isActiveState else { return false }
        // check current player's playback state
        guard let playbackState = currentPlayer?.playbackState else { return true }
        if playbackState.isActiveState {
            return false
        } else {
            return true
        }
    }
}

