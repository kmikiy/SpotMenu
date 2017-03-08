//
//  config.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 02. 28..
//  Copyright © 2017. KM. All rights reserved.
//

import Foundation

public class Config {
    static let authUrls: AuthUrls = AuthUrls.shared
    
}

public class AuthUrls {
    static let shared = AuthUrls()
    private static let _baseUrl = "https://kmikiy-for-spotify.herokuapp.com"
    let base = AuthUrls._baseUrl
    let login = AuthUrls._baseUrl + "/login"
    let refreshToken = AuthUrls._baseUrl + "/refresh_token"
}
