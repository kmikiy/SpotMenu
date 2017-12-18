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

    // MARK: - Properties

    fileprivate var defaultMoreInformationText: String = NSLocalizedString("Hover over an option for more information.", comment: "")

    // MARK: - IBOutlets

    @IBOutlet fileprivate var automaticallyCheckForUpdatesButton: HoverButton!
    @IBOutlet fileprivate var automaticallyDownloadUpdatesButton: HoverButton!
    @IBOutlet fileprivate var lastUpdateCheckLabel: NSTextField!
    @IBOutlet fileprivate var moreInformation: NSTextField!
    @IBOutlet var checkForUpdatesButton: NSButton!
    @IBOutlet var lastCheckedLabel: NSTextField!
    @IBOutlet var withLoveFromKmikiy: NSTextField!

    // MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        initLabels()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        moreInformation.stringValue = defaultMoreInformationText
        initButtonStates()
        initButtonHovers()
        if SUUpdater.shared().lastUpdateCheckDate != nil {
            lastUpdateCheckLabel.stringValue = SUUpdater.shared().lastUpdateCheckDate.asString()
        }
    }

    private func initLabels() {
        automaticallyCheckForUpdatesButton.title = NSLocalizedString("Automatically check for updates", comment: "")
        automaticallyDownloadUpdatesButton.title = NSLocalizedString("Automatically download updates", comment: "")
        lastCheckedLabel.stringValue = NSLocalizedString("Last checked:", comment: "")
        checkForUpdatesButton.title = NSLocalizedString("Check for Updates", comment: "")
        withLoveFromKmikiy.stringValue = NSLocalizedString("with ♥ from kmikiy", comment: "")
    }

    private func initButtonStates() {
        automaticallyCheckForUpdatesButton.state = NSControl.StateValue(rawValue: SUUpdater.shared().automaticallyChecksForUpdates.asState)
        automaticallyDownloadUpdatesButton.state = NSControl.StateValue(rawValue: SUUpdater.shared().automaticallyDownloadsUpdates.asState)
    }

    private func initButtonHovers() {
        automaticallyCheckForUpdatesButton.mouseEnteredFunc = hoverAutomaticallyCheckForUpdates
        automaticallyCheckForUpdatesButton.mouseExitedFunc = hoverAway

        automaticallyDownloadUpdatesButton.mouseEnteredFunc = hoverAutomaticallyDownloadUpdates
        automaticallyDownloadUpdatesButton.mouseExitedFunc = hoverAway
    }

    // MARK: - IBActions

    @IBAction func toggleAutomaticallyCheckForUpdates(_: Any) {
        SUUpdater.shared().automaticallyChecksForUpdates = automaticallyCheckForUpdatesButton.state.asBool
    }

    @IBAction func toggleAutomaticallyDownloadUpdates(_: Any) {
        SUUpdater.shared().automaticallyDownloadsUpdates = automaticallyDownloadUpdatesButton.state.asBool
    }

    @IBAction func CheckForUpdates(_ sender: Any) {
        SUUpdater.shared().checkForUpdates(sender)
        if SUUpdater.shared().lastUpdateCheckDate != nil {
            lastUpdateCheckLabel.stringValue = SUUpdater.shared().lastUpdateCheckDate.asString()
        }
    }
}

// MARK: - Hover button methods

extension UpdatesPreferencesVC {

    fileprivate func hoverAutomaticallyCheckForUpdates() {
        moreInformation.stringValue = NSLocalizedString("Indicates whether or not to check for updates automatically.", comment: "")
    }

    fileprivate func hoverAutomaticallyDownloadUpdates() {
        moreInformation.stringValue = NSLocalizedString("Indicates whether or not updates can be automatically downloaded in the background.", comment: "")
    }

    fileprivate func hoverAway() {
        moreInformation.stringValue = defaultMoreInformationText
    }
}

extension Date {
    func asString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}
