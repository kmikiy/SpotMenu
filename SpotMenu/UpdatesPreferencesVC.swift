//
//  UpdatesPreferencesVC.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 09. 03..
//  Copyright © 2017. KM. All rights reserved.
//

import Cocoa
import Sparkle

final class UpdatesPreferencesVC: NSViewController {

    // MARK: - IBOutlets
    
    @IBOutlet fileprivate weak var automaticallyCheckForUpdatesButton: HoverButton!
    @IBOutlet fileprivate weak var automaticallyDownloadUpdatesButton: HoverButton!
    @IBOutlet fileprivate weak var lastUpdateCheckLabel: NSTextField!

    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        initButtonStates()
        lastUpdateCheckLabel.stringValue = SUUpdater.shared().lastUpdateCheckDate.asString()
    }
    
    private func initButtonStates(){
        automaticallyCheckForUpdatesButton.state = SUUpdater.shared().automaticallyChecksForUpdates.asState
        automaticallyDownloadUpdatesButton.state = SUUpdater.shared().automaticallyDownloadsUpdates.asState
    }
    
    // MARK: - IBActions
    
    @IBAction func toggleAutomaticallyCheckForUpdates(_ sender: Any) {
        SUUpdater.shared().automaticallyChecksForUpdates = automaticallyCheckForUpdatesButton.state.asBool
    }
    
    
    @IBAction func toggleAutomaticallyDownloadUpdates(_ sender: Any) {
        SUUpdater.shared().automaticallyDownloadsUpdates = automaticallyDownloadUpdatesButton.state.asBool
    }
    
    @IBAction func CheckForUpdates(_ sender: Any) {
        SUUpdater.shared().checkForUpdates(sender)
        lastUpdateCheckLabel.stringValue = SUUpdater.shared().lastUpdateCheckDate.asString()
    }
}

extension Date {
    func asString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"
        let dateString = dateFormatter.string(from:self)
        return dateString
    }
}
