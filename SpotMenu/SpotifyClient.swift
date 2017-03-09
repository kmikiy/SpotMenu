//
//  SpotifyUser.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 02. 28..
//  Copyright © 2017. KM. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

open class SpotifyClient {
    static let shared = SpotifyClient()
    let me: Me = Me.shared
    private init(){}
    let sessionManager = SessionManager()
}

class Me {
    static let shared = Me()
    let tracks: Tracks = Tracks.shared
    
    var accessToken: String?
    var refreshToken: String?
    var id: String?
    
    func about(completion: ((_ result:String) -> Void)?) {
        
    }
    
    func signOut() -> Void {
        accessToken = nil
        refreshToken = nil
        URLCache.shared.removeAllCachedResponses()
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }
    private init(){}
}

class Tracks {
    static let shared = Tracks()
    private init(){}
    
    static func saveTrack(completion: (_ result: String) -> Void){
        //TODO
        print("save track")
    }
    
    func deleteTrack(completion: (_ result: String) -> Void) -> Void {
        
    }
    
    func isTrackSaved(id: String, completion: (_ result: Bool) -> Void) {
        
        print("printing access token")
        print(SpotifyClient.shared.me.accessToken!)
        SpotifyClient.shared.sessionManager.adapter = AccessTokenAdapter(accessToken: SpotifyClient.shared.me.accessToken!)
        
        let url = "https://api.spotify.com/v1/me/tracks/contains"
        let _id = "1YpGWVpnewRIuodSTJ3WGs"
        SpotifyClient.shared.sessionManager.request(url, parameters: ["ids": _id]).responseJSON { response in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                json[0].boolValue
                print("JSON: \(json)")
            case .failure(let error):
                print("EERROR ÁG")
                print(error)
            }
        }
        //response: [true, false, ...]
    }
}

class AccessTokenAdapter: RequestAdapter {
    private let accessToken: String
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix("https://api.spotify.com") {
            urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        }
        
        return urlRequest
    }
}
