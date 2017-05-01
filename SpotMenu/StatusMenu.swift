//
//  StatusMenu.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 05. 01..
//  Copyright © 2017. KM. All rights reserved.
//

import Foundation
import Cocoa

class StatusMenu {
    
    var menu = NSMenu()
    
    init() {
       
       
        menu.addItem(NSMenuItem(title: "Issues", action: #selector(AppDelegate.openSite(_:)), keyEquivalent: "I"))
        menu.addItem(NSMenuItem(title: " - kmikiy - ", action: #selector(AppDelegate.openSite(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(AppDelegate.openPrefs(_:)), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(AppDelegate.quit(_:)), keyEquivalent: "Q"))
    }
    
}
