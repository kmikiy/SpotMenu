//
//  LaunchStarter.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 05. 21..
//  Copyright © 2017. KM. All rights reserved.
//

import Foundation
import LoginServiceKit

func applicationIsInStartUpItems() -> Bool {
    let appPath = Bundle.main.bundlePath
    return LoginServiceKit.isExistLoginItems(at: appPath)
}

func toggleLaunchAtStartup() {
    let appPath = Bundle.main.bundlePath
    if applicationIsInStartUpItems() {
        LoginServiceKit.removeLoginItems(at: appPath)
    } else {
        LoginServiceKit.addLoginItems(at: appPath)
    }
}
