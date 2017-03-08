//
//  SpotifyLogin.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 02. 28..
//  Copyright © 2017. KM. All rights reserved.
//

import Foundation
import AppKit
import WebKit

class SpotifyLogin: NSWindowController {
    
    @IBOutlet weak var webView: WebView!
    init() {
        super.init(window: nil)

        /* Load window from xib file */
        Bundle.main.loadNibNamed("SpotifyLogin", owner: self, topLevelObjects: nil)
        let url = URL(string: "https://kmikiy-for-spotify.herokuapp.com/login")
        let urlRequest = URLRequest(url: url!)
        webView.mainFrame.load(urlRequest)
        webView.isEditable = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func windowDidLoad() {
        print("juppi")
    }
}
