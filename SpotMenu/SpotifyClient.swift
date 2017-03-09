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


struct Token {
    var accessToken: String
    var refreshToken: String
}

class Me {
    static let shared = Me()
    let tracks: Tracks = Tracks.shared
    
    var accessToken: String?
    var refreshToken: String?
    var id: String?
    var bestBefore: Date?
    
    func about(completion: ((_ result:String) -> Void)?) {
        
    }
    
    func signOut() -> Void {
        accessToken = nil
        refreshToken = nil
        bestBefore = nil
        URLCache.shared.removeAllCachedResponses()
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }
    
    func setUser(tokens: Token) -> Void {
        accessToken = tokens.accessToken
        refreshToken = tokens.refreshToken
        bestBefore = Date(timeIntervalSinceNow: 20)
        SpotifyClient.shared.sessionManager.adapter = AccessTokenAdapter(accessToken: tokens.accessToken)
    }
    
    func refresh() {
        if let _refreshToken = refreshToken {
            Alamofire.request(Config.authUrls.refreshToken, parameters: ["refresh_token": _refreshToken]).responseJSON{ response in
                switch response.result{
                case .success(let value):
                    let json = JSON(value)
                    self.accessToken = json["access_token"].stringValue
                    let delta = json["expires_in"].intValue - 200
                    self.bestBefore = Date(timeIntervalSinceNow: TimeInterval(delta))
                    
                    //print("JSON: \(json)")
                case .failure(let error):
                    print("EERROR ÁG")
                    print(error)
                }
                
            }
        }
        
    }
    
    private init(){}
}

class Tracks {
    static let shared = Tracks()
    private init(){}
    
    func saveTrack(id: String, completion: @escaping () -> Void){
        let url = "https://api.spotify.com/v1/me/tracks"
        let ids = [id]
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: ids)
        SpotifyClient.shared.sessionManager.request(request).responseData { response in
            switch response.result{
            case .success(let value):
                completion()
                
            case .failure(let error):
                print("EERROR ÁG")
                print(error)
                
            }
        }
    }
    
    func deleteTrack(id: String, completion: @escaping () -> Void) {
        let url = "https://api.spotify.com/v1/me/tracks"
        SpotifyClient.shared.sessionManager.request(url, method: .delete, parameters: ["ids": id]).responseData { response in
            switch response.result{
            case .success(let value):
                completion()
                
            case .failure(let error):
                print("EERROR ÁG")
                print(error)
            }
        }
    }
    
    func isTrackSaved(id: String, completion: @escaping (_ result: Bool) -> Void) {
        
        let url = "https://api.spotify.com/v1/me/tracks/contains"
        SpotifyClient.shared.sessionManager.request(url, parameters: ["ids": id]).responseJSON { response in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                completion(json[0].boolValue)
                
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
        
        if let bestBeforeDate = SpotifyClient.shared.me.bestBefore {
            let delta = Date().timeIntervalSince(bestBeforeDate)
            if delta > -20 {
                SpotifyClient.shared.me.refresh()
            }
        }
        
        return urlRequest
    }
}
