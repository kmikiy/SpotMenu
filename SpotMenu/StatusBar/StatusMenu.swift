//
//  StatusMenu.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 05. 01..
//  Copyright © 2017. KM. All rights reserved.
//

import Cocoa
import Foundation
import Sparkle

final class StatusMenu {

    // MARK: - Properties

    let menu = NSMenu()

    // MARK: - Lifecycle methods

    init() {

        menu.addItem(NSMenuItem(
            title: NSLocalizedString("Issues", comment: ""),
            action: #selector(AppDelegate.openIssues(_:)),
            keyEquivalent: "I")
        )
        menu.addItem(NSMenuItem(
            title: NSLocalizedString(" - kmikiy - ", comment: ""),
            action: #selector(AppDelegate.openKmikiy(_:)),
            keyEquivalent: "")
        )
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(
            title: NSLocalizedString("Check for Updates...", comment: ""),
            action: #selector(AppDelegate.checkForUpdates(_:)),
            keyEquivalent: "")
        )
        menu.addItem(NSMenuItem(
            title: NSLocalizedString("Preferences...", comment: ""),
            action: #selector(AppDelegate.openPrefs(_:)),
            keyEquivalent: ",")
        )
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(
            title: NSLocalizedString("Quit", comment: ""),
            action: #selector(AppDelegate.quit(_:)),
            keyEquivalent: "Q")
        )
    }
}
