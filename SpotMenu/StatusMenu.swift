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
       
       
        menu.addItem(NSMenuItem(title:  NSLocalizedString("Issues", comment:""), action: #selector(AppDelegate.openSite(_:)), keyEquivalent: "I"))
        menu.addItem(NSMenuItem(title: NSLocalizedString(" - kmikiy - ", comment:""), action: #selector(AppDelegate.openSite(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: NSLocalizedString("Preferences...", comment:""), action: #selector(AppDelegate.openPrefs(_:)), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: NSLocalizedString("Quit", comment:""), action: #selector(AppDelegate.quit(_:)), keyEquivalent: "Q"))
    }
    
}
