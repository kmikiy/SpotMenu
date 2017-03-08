//
//  L.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 03. 06..
//  Copyright © 2017. KM. All rights reserved.
//

import Foundation

import WebKit
class L: NSViewController {
    @IBOutlet weak var webView: WebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //Bundle.main.loadNibNamed("SpotifyLogin", owner: self, topLevelObjects: nil)
//        let url = URL(string: "https://kmikiy-for-spotify.herokuapp.com/login")
//        let urlRequest = URLRequest(url: url!)
//        webView.mainFrame.load(urlRequest)
        webView.mainFrame.load(URLRequest(url: URL(string: Config.authUrls.login)!))
    }
}
