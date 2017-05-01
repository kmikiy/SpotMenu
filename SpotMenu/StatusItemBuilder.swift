//
//  StatusItemBuilder.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 05. 01..
//  Copyright © 2017. KM. All rights reserved.
//

import Foundation
import Spotify

class StatusItemBuilder {
    
    var title = ""
    var artist = ""
    var state: PlayerState
    var playingIcon = ""
    
    init() {
        self.state = Spotify.playerState
    }
    func showTitle(v: Bool) -> StatusItemBuilder {
        if !v {
            self.title = ""
            return self
        }
        if let title = Spotify.currentTrack.title {
            self.title = title + " "
        }
        return self
    }
    
    func showArtist(v: Bool) -> StatusItemBuilder {
        if !v {
            self.artist = ""
            return self
        }
        if let artist = Spotify.currentTrack.artist {
            self.artist = artist + " "
        }
        return self
    }

    
    func showAlbumArtist(v: Bool) -> StatusItemBuilder {
        if !v {
            self.artist = ""
            return self
        }
        if let artist = Spotify.currentTrack.albumArtist {
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
        
        //  statusItem.title = "♫ \(artist) - \(title)  "
    }
}
