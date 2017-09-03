//
//  PreferencesWindowController.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 09. 03..
//  Copyright © 2017. KM. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {

    @IBOutlet weak var toolbar: NSToolbar!
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.contentViewController =  NSStoryboard(name: "Preferences", bundle: nil).instantiateController(withIdentifier: "General") as? NSViewController
        toolbar.selectedItemIdentifier = "general"
    }

    @IBAction func GeneralSelected(_ sender: Any) {
        toolbar.selectedItemIdentifier = "general"
        self.contentViewController =  NSStoryboard(name: "Preferences", bundle: nil).instantiateController(withIdentifier: "General") as? NSViewController
    }
    
    @IBAction func UpdatesSelected(_ sender: Any) {
        toolbar.selectedItemIdentifier = "updates"
    }
    
    
}
