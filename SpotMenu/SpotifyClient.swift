//
//  SpotifyUser.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 02. 28..
//  Copyright © 2017. KM. All rights reserved.
//

import Foundation
open class SpotifyUser {
    var accessToken: String?
    var refreshToken: String?
    var id: String?
}

open class SpotifyClient {
    static let shared = SpotifyClient()
    let me: Me = Me.shared
    private init(){}
}

class Me {
    static let shared = Me()
    let tracks: Tracks = Tracks.shared
    private init(){}
}

class Tracks {
    static let shared = Tracks()
    private init(){}
    
    func saveTrack() -> Void {
        //TODO
        print("save track")
    }
    
    func deleteTrack() -> Void {
        
    }
}
