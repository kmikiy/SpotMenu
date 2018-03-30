//
//  StatusItemBuilder.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 05. 01..
//  Copyright © 2017. KM. All rights reserved.
//

import Foundation

final class StatusItemBuilder {

    // MARK: - Properties

    private var title = ""
    private var artist = ""
    private var albumName = ""
    private var playingIcon = ""
    private var isPlaying: Bool = false
    private var hideWhenPaused = false
    private var scrollStatus = 0
    private var currentTitle = ""
    private var statusUpdateTimer: Timer?
    private var shortInterval = TimeInterval(0.5)
    private var longInterval = TimeInterval(2)
    private var maxLength = UserPreferences.scrollStatusBarIfLengthOver
    private var maxLengthBuffer = 5

    // MARK: - Lifecycle method

    init(title: String?, artist: String?, albumName: String?, isPlaying: Bool) {
        update(title: title, artist: artist, albumName: albumName, isPlaying: isPlaying)
    }

    // MARK: - Methods

    func update(title: String?, artist: String?, albumName: String?, isPlaying: Bool) -> StatusItemBuilder {
        if let v = title {
            self.title = v
        }
        if let v = artist {
            self.artist = v
        }
        if let v = albumName {
            self.albumName = v
        }
        self.isPlaying = isPlaying
        scrollStatus = 0
        if statusUpdateTimer != nil {
            statusUpdateTimer?.invalidate()
            statusUpdateTimer = nil
        }
        currentTitle = getString()
        return self
    }

    func hideWhenPaused(v: Bool) -> StatusItemBuilder {
        hideWhenPaused = v
        return self
    }

    func showTitle(v: Bool) -> StatusItemBuilder {
        if !v {
            title = ""
            return self
        }
        if !isPlaying && hideWhenPaused {
            title = ""
            return self
        }
        return self
    }

    func showArtist(v: Bool) -> StatusItemBuilder {
        if !v {
            artist = ""
            return self
        }
        if !isPlaying && hideWhenPaused {
            artist = ""
            return self
        }
        return self
    }

    func showAlbumName(v: Bool) -> StatusItemBuilder {
        if !v {
            albumName = ""
            return self
        }
        if !isPlaying && hideWhenPaused {
            albumName = ""
            return self
        }
        return self
    }

    func showPlayingIcon(v: Bool) -> StatusItemBuilder {
        if !v {
            playingIcon = ""
            return self
        }
        if isPlaying {
            playingIcon = "♫ "
        } else {
            playingIcon = ""
        }
        return self
    }

    func setTitle(callback: @escaping (_ newTitle: String) -> ()) {
        if !isPlaying && UserPreferences.hideTitleArtistWhenPaused {
            callback("")
            return
        }
        if maxLength == 0 {
            maxLength = 40
        }
        if currentTitle.count > (maxLength + maxLengthBuffer) {
            var startIndex = currentTitle.index(currentTitle.startIndex, offsetBy: scrollStatus)
            if (scrollStatus + maxLength) > currentTitle.count {
                startIndex = currentTitle.startIndex
                scrollStatus = 0
            }
            let endIndex = currentTitle.index(startIndex, offsetBy: maxLength)
            let viewablePortionOfLabel = String(currentTitle[startIndex..<endIndex])

            callback("\(playingIcon)\(viewablePortionOfLabel)")

            if isPlaying && currentTitle != "" {
                var interval = shortInterval
                if scrollStatus == 0 || (scrollStatus + maxLength) == currentTitle.count {
                    interval = longInterval
                }
                if #available(OSX 10.12, *) {
                    statusUpdateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) {
                        (_) in
                            self.setTitle(callback: callback)
                    }
                }
            }
            scrollStatus += 1

        } else {
            if statusUpdateTimer != nil {
                statusUpdateTimer?.invalidate()
                statusUpdateTimer = nil
            }
            scrollStatus = 0
            callback("\(playingIcon)\(currentTitle)")
        }
    }

    func getString() -> String {
        if artist.count != 0 && title.count != 0 && albumName.count != 0 {
            return "\(artist) - \(title) - \(albumName)"
        } else if artist.count != 0 && title.count != 0 {
            return "\(artist) - \(title)"
        }
        return "\(artist)\(title)"
    }
}
