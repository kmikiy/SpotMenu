//
//  StatusItemBuilder.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 05. 01..
//  Copyright © 2017. KM. All rights reserved.
//

import Foundation
import SpotifyAppleScript

final class StatusItemBuilder {
    
    // MARK: - Properties
    
    private var title = ""
    
    private var artist = ""
    
    private var playingIcon = ""
    
    private var state: PlayerState
    
    // MARK: - Lifecycle method
    
    init() {
        state = SpotifyAppleScript.playerState
    }
    
    // MARK: - Methods
    
    func showTitle(v: Bool) -> StatusItemBuilder {
        if !v {
            title = ""
            return self
        }
        if let title = SpotifyAppleScript.currentTrack.title {
            self.title = title + " "
        }
        return self
    }
    
    func showArtist(v: Bool) -> StatusItemBuilder {
        if !v {
            artist = ""
            return self
        }
        if let artist = SpotifyAppleScript.currentTrack.artist {
            self.artist = artist + " "
        }
        return self
    }
    
    func showAlbumArtist(v: Bool) -> StatusItemBuilder {
        if !v {
            artist = ""
            return self
        }
        if let artist = SpotifyAppleScript.currentTrack.albumArtist {
            self.artist = artist + " "
        }
        return self
    }
    
    func showPlayingIcon(v: Bool) -> StatusItemBuilder {
        if !v {
            playingIcon = ""
            return self
        }
        if (state == PlayerState.playing) {
            playingIcon = "♫ "
        } else {
            playingIcon = ""
        }
        return self
    }
    
    func getString() -> String {
        if( artist.characters.count != 0 && title.characters.count != 0 ) {
            return "\(playingIcon)\(artist)- \(title)"
        }
        return "\(playingIcon)\(artist)\(title)"
    }
}
