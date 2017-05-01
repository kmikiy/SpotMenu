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
    func showTitle() -> StatusItemBuilder {
        if let title = Spotify.currentTrack.title {
            self.title = title + " "
        }
        return self
    }
    func hideTitle() -> StatusItemBuilder {
        self.title = ""
        return self
    }
    func showArtist() -> StatusItemBuilder {
        if let artist = Spotify.currentTrack.artist {
            self.artist = artist + " "
        }
        return self
    }
    
    func hideArtist() -> StatusItemBuilder {
        self.artist = ""
        return self
    }
    
    func showAlbumArtist() -> StatusItemBuilder {
        if let artist = Spotify.currentTrack.albumArtist {
            self.artist = artist + " "
        }
        return self
    }
    
    func showPlayingIcon() -> StatusItemBuilder {
        if (state == PlayerState.playing) {
            playingIcon = "♫ "
        } else {
            playingIcon = ""
        }
        return self
    }
    func hidePlayingIcon() -> StatusItemBuilder {
        playingIcon = ""
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
