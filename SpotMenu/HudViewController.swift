//
//  ViewController.swift
//  Toast
//
//  Created by toshi0383 on 2016/10/23.
//
//

import Foundation
import AppKit
import Spotify

class ViewController: NSViewController {
    var toggle = true
    override func viewDidAppear() {
        super.viewDidAppear()
        view.makeToast(StatusItemBuilder()
            .showTitle(v: true)
            .showArtist(v: true)
            .showPlayingIcon(v: true)
            .getString())

    }
}

class WindowController : NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        
        super.window?.backgroundColor = NSColor(calibratedRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
    }
}
