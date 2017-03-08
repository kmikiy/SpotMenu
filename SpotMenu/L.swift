//
//  L.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 03. 06..
//  Copyright © 2017. KM. All rights reserved.
//

import Foundation

import WebKit
class L: NSViewController, WebFrameLoadDelegate , WebResourceLoadDelegate{
    @IBOutlet weak var webView: WebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //Bundle.main.loadNibNamed("SpotifyLogin", owner: self, topLevelObjects: nil)
        //        let url = URL(string: "https://kmikiy-for-spotify.herokuapp.com/login")
        //        let urlRequest = URLRequest(url: url!)
        //        webView.mainFrame.load(urlRequest)
        webView.mainFrame.load(URLRequest(url: URL(string: Config.authUrls.login)!))
        webView.frameLoadDelegate = self
        webView.resourceLoadDelegate = self
    }
    
    func webView(_ sender: WebView!, willPerformClientRedirectTo URL: URL!, delay seconds: TimeInterval, fire date: Date!, for frame: WebFrame!) {
        print(URL)
    }
    
    @IBAction func dissmissAction(_ sender: Any) {
        self.presenting?.dismissViewController(self)
    }
    
    func webView(_ sender: WebView!, resource identifier: Any!, willSend request: URLRequest!, redirectResponse: URLResponse!, from dataSource: WebDataSource!) -> URLRequest! {

        if let fragmentDictionary = request.url?.fragmentDictionary {
            print("fragment dictionary")
            print(fragmentDictionary)

            self.presenting?.dismissViewController(self)
            return nil
        }
        
        if (self.presenting?.presentedViewControllers?.count) != 0 {
            return request
        } else {
            return nil
        }
        
    }
 
}


extension URL
{
    var fragmentDictionary:[String: [String]]? {
        get {
            if let query = self.fragment {
                var dictionary = [String: [String]]()
                
                for keyValueString in query.components(separatedBy: "&") {
                    var parts = keyValueString.components(separatedBy: "=")
                    if parts.count < 2 { continue; }
                    
                    let key = parts[0].removingPercentEncoding!
                    let value = parts[1].removingPercentEncoding!
                    
                    var values = dictionary[key] ?? [String]()
                    values.append(value)
                    dictionary[key] = values
                }
                
                return dictionary
            }
            
            return nil
        }
    }
}
 
/*
extension NSURL {
    var fragmentItems: [String: String]? {
        var params = [String: String]()
        return NSURLComponents(url: self as URL, resolvingAgainstBaseURL: false)?
            .fragment?
            .reduce([:], { (_, item) -> [String: String] in
                params[item.name] = item.value
                return params
            })
    }
}
 */
