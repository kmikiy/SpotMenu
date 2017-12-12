//
//  PreferencesWindowController.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 09. 15..
//  Copyright © 2017. KM. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {

    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var preferencesWindow: NSWindow!
    
    // MARK: - Lifecycle methods

    override func windowDidLoad() {
        super.windowDidLoad()
        initLabels()
        
        self.window?.setFrame(NSMakeRect(0, 0, 500, 300), display: true)
        self.window?.center()
    }
    
    private func initLabels(){
        preferencesWindow.title = NSLocalizedString("Preferences", comment: "")
    }

}
