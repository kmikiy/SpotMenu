//
//  PreferencesWindowController.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 09. 03..
//  Copyright © 2017. KM. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {

    var prevWindowFrame = NSRect()
    @IBOutlet weak var toolbar: NSToolbar!
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.contentViewController =  NSStoryboard(name: "Preferences", bundle: nil).instantiateController(withIdentifier: "GeneralID") as? NSViewController
        toolbar.selectedItemIdentifier = "general"
        if let w = self.window {
            prevWindowFrame = w.frame
        }
    }

    @IBAction func GeneralSelected(_ sender: Any) {
        toolbar.selectedItemIdentifier = "general"
        if let w = self.window {
            prevWindowFrame = w.frame
        }
        self.contentViewController =  NSStoryboard(name: "Preferences", bundle: nil).instantiateController(withIdentifier: "GeneralID") as? NSViewController
        if let w = self.window {
            w.setFrame(prevWindowFrame, display: true)
        }
    }
    
    @IBAction func UpdatesSelected(_ sender: Any) {
        toolbar.selectedItemIdentifier = "updates"
        if let w = self.window {
            prevWindowFrame = w.frame
        }
        self.contentViewController =  NSStoryboard(name: "Preferences", bundle: nil).instantiateController(withIdentifier: "UpdatesID") as? NSViewController
        if let w = self.window {
            w.setFrame(prevWindowFrame, display: true)
        }
    }
}
