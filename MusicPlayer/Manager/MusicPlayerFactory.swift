//
//  MusicPlayerFactory.swift
//  MusicPlayer
//
//  Created by Michael Row on 2017/9/3.
//

import Foundation

class MusicPlayerFactory {
    
    static func musicPlayer(name: MusicPlayerName) -> MusicPlayer? {
        switch name {
        case .iTunes:
            return iTunes()
        case .spotify:
            return Spotify()
        case .vox:
            return Vox()
        }
    }
    
    private init() {}
}
