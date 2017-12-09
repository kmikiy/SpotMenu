//
//  PreferencesWindow.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 05. 01..
//  Copyright © 2017. KM. All rights reserved.
//

import Foundation
import Cocoa

final class GeneralPreferencesVC: NSViewController {
    
    // MARK: - Properties
    
    fileprivate var defaultMoreInformationText: String = NSLocalizedString("Hover over an option for more information.", comment: "")
    
    // MARK: - IBOutlets
    
    @IBOutlet fileprivate weak var showArtistButton: HoverButton!
    @IBOutlet fileprivate weak var showTitleButton: HoverButton!
    @IBOutlet fileprivate weak var showAlbumNameButton: HoverButton!
    @IBOutlet fileprivate weak var showPlayingIconButton: HoverButton!
    @IBOutlet fileprivate weak var showSpotMenuIconButton: HoverButton!
    @IBOutlet fileprivate weak var fixPopoverToTheRightButton: HoverButton!
    @IBOutlet fileprivate weak var openAtLoginButton: HoverButton!
    @IBOutlet fileprivate weak var enableKeyboardShortcutButton: HoverButton!
    @IBOutlet fileprivate weak var hideTextWhenPausedButton: HoverButton!
    @IBOutlet fileprivate weak var moreInformation: NSTextField!
    @IBOutlet private weak var withLoveFromKmikiyText: NSTextField!

    
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
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func initLabels(){
        showArtistButton.title = NSLocalizedString("Show artist", comment: "")
        showTitleButton.title =  NSLocalizedString("Show title", comment: "")
        showAlbumNameButton.title = NSLocalizedString("Show album title", comment: "")
        showPlayingIconButton.title = NSLocalizedString("Show playing icon", comment: "")
        showSpotMenuIconButton.title = NSLocalizedString("Show SpotMenu icon", comment: "")
        fixPopoverToTheRightButton.title = NSLocalizedString("Fix popover to the right", comment: "")
        openAtLoginButton.title = NSLocalizedString("Open at login", comment: "")
        enableKeyboardShortcutButton.title = NSLocalizedString("Enable keyboard shortcut", comment: "")
        hideTextWhenPausedButton.title = NSLocalizedString("Hide text when paused", comment: "")
        withLoveFromKmikiyText.stringValue = NSLocalizedString("with ♥ from kmikiy", comment: "")
    }
    
    private func initButtonStates(){
        showArtistButton.state = NSControl.StateValue(rawValue: UserPreferences.showArtist.asState)
        showTitleButton.state =  NSControl.StateValue(rawValue: UserPreferences.showTitle.asState)
        showAlbumNameButton.state = NSControl.StateValue(rawValue: UserPreferences.showAlbumName.asState)
        showPlayingIconButton.state = NSControl.StateValue(rawValue: UserPreferences.showPlayingIcon.asState)
        showSpotMenuIconButton.state = NSControl.StateValue(rawValue: UserPreferences.showSpotMenuIcon.asState)
        fixPopoverToTheRightButton.state = NSControl.StateValue(rawValue: UserPreferences.fixPopoverToTheRight.asState)
        openAtLoginButton.state = NSControl.StateValue(rawValue: applicationIsInStartUpItems().asState)
        enableKeyboardShortcutButton.state = NSControl.StateValue(rawValue: UserPreferences.keyboardShortcutEnabled.asState)
        hideTextWhenPausedButton.state = NSControl.StateValue(rawValue: UserPreferences.hideTitleArtistWhenPaused.asState)
    }
    
    private func initButtonHovers(){
        showArtistButton.mouseEnteredFunc = hoverShowArtist
        showArtistButton.mouseExitedFunc = hoverAway
        
        showTitleButton.mouseEnteredFunc = hoverShowTitle
        showTitleButton.mouseExitedFunc = hoverAway
        
        showAlbumNameButton.mouseEnteredFunc = hoverShowAlbumName
        showAlbumNameButton.mouseEnteredFunc = hoverAway
        
        showPlayingIconButton.mouseEnteredFunc = hoverShowPlayingIcon
        showPlayingIconButton.mouseExitedFunc = hoverAway
        
        showSpotMenuIconButton.mouseEnteredFunc = hoverShowSpotMenuIcon
        showSpotMenuIconButton.mouseExitedFunc = hoverAway
        
        fixPopoverToTheRightButton.mouseEnteredFunc = hoverFixPopoverToTheRight
        fixPopoverToTheRightButton.mouseExitedFunc = hoverAway
        
        openAtLoginButton.mouseEnteredFunc = hoverOpenAtLogin
        openAtLoginButton.mouseExitedFunc = hoverAway
        
        hideTextWhenPausedButton.mouseEnteredFunc = hoverHideTitleWhenPaused
        hideTextWhenPausedButton.mouseExitedFunc = hoverAway
        
        enableKeyboardShortcutButton.mouseEnteredFunc = hoverEnableKeyboardShortcut
        enableKeyboardShortcutButton.mouseExitedFunc = hoverAway
    }
    
    // MARK: - IBActions
    
    @IBAction private func toggleShowArtist(_ sender: Any) {
        UserPreferences.showArtist = showArtistButton.state.asBool
        postUpdateNotification()
    }
    
    @IBAction private func toggleShowTitle(_ sender: Any) {
        UserPreferences.showTitle = showTitleButton.state.asBool
        postUpdateNotification()
    }
    
    @IBAction private func toggleShowAlbumName(_ sender: Any) {
        UserPreferences.showAlbumName = showAlbumNameButton.state.asBool
        postUpdateNotification()
    }
    
    @IBAction private func toggleShowPlayingIcon(_ sender: Any) {
        UserPreferences.showPlayingIcon = showPlayingIconButton.state.asBool
        postUpdateNotification()
    }
    
    @IBAction private func toggleShowSpotMenuIcon(_ sender: Any) {
        UserPreferences.showSpotMenuIcon = showSpotMenuIconButton.state.asBool
        postUpdateNotification()
        postUpdateNotification()
    }
    
    @IBAction private func toggleFixPopoverToTheRight(_ sender: Any) {
        UserPreferences.fixPopoverToTheRight = fixPopoverToTheRightButton.state.asBool
        //postUpdateNotification()
    }
    
    @IBAction private func toggleOpenAtLogin(_ sender: Any) {
        toggleLaunchAtStartup()
        openAtLoginButton.state = NSControl.StateValue(rawValue: applicationIsInStartUpItems().asState)
    }
    
    @IBAction func toggleHideTextWhenPaused(_ sender: Any) {
        UserPreferences.hideTitleArtistWhenPaused = hideTextWhenPausedButton.state.asBool
        postUpdateNotification()
    }
    
    @IBAction func toggleEnableKeyboardShortcut(_ sender: Any) {
        UserPreferences.keyboardShortcutEnabled = enableKeyboardShortcutButton.state.asBool
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        if UserPreferences.keyboardShortcutEnabled {
            appDelegate.registerHotkey()
        } else {
            appDelegate.unregisterHotKey()
        }
    }
    
    // MARK: - Private methods
    
    private func postUpdateNotification(){
       // NotificationCenter.default.post(name: Notification.Name(rawValue: InternalNotification.key), object: self)
    }
    
}

// MARK: - Hover button methods

extension GeneralPreferencesVC {
    
    fileprivate func hoverShowArtist() {
        moreInformation.stringValue = NSLocalizedString("When checked the artist will be shown in the menu bar.", comment: "")
    }
    
    fileprivate func hoverShowTitle() {
        moreInformation.stringValue = NSLocalizedString("When checked the title will be shown in the menu bar.", comment: "")
    }
    
    fileprivate func hoverShowAlbumName() {
        moreInformation.stringValue = NSLocalizedString("When checked the album name will be shown in the menu bar.", comment: "")
    }
    
    fileprivate func hoverShowPlayingIcon() {
        moreInformation.stringValue = NSLocalizedString("When checked the playing icon (♫) will be shown in the menu bar if music is played.", comment: "")
    }
    
    fileprivate func hoverShowSpotMenuIcon() {
        moreInformation.stringValue = NSLocalizedString("When checked the SpotMenu icon will be shown in the menu bar. Note: If there is no music information to be shown the SpotMenu icon will be visible.", comment: "")
    }
    
    fileprivate func hoverFixPopoverToTheRight() {
        moreInformation.stringValue = NSLocalizedString("When checked the popover will be fixed to the right corner.", comment: "")
    }
    
    fileprivate func hoverOpenAtLogin() {
        moreInformation.stringValue = NSLocalizedString("When checked SpotMenu will start automatically at login.", comment: "")
    }
    
    fileprivate func hoverEnableKeyboardShortcut() {
        moreInformation.stringValue = NSLocalizedString("Display the current song artist and title by pressing ctrl + command + m.", comment: "")
    }
    
    fileprivate func hoverHideTitleWhenPaused() {
        moreInformation.stringValue = NSLocalizedString("Omits the current song artist and title from the menu bar when the music is paused.", comment: "")
    }
    
    fileprivate func hoverAway() {
        moreInformation.stringValue = defaultMoreInformationText
    }
}


