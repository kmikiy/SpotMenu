//
//  PreferencesWindow.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 05. 01..
//  Copyright © 2017. KM. All rights reserved.
//

import Foundation
import Cocoa
import Spotify


class GeneralPreferencesVC: NSViewController {
    
    @IBOutlet weak var showArtistButton: HoverButton!
    @IBOutlet weak var showTitleButton: HoverButton!
    @IBOutlet weak var showPlayingIconButton: HoverButton!
    @IBOutlet weak var showSpotMenuIconButton: HoverButton!
    
    @IBOutlet weak var moreInformation: NSTextField!
    var defaultMoreInformationText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultMoreInformationText = moreInformation.stringValue
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        moreInformation.stringValue = defaultMoreInformationText
        initButtonStates()
        initButtonHovers()
    }
    
    func initButtonStates(){
        showArtistButton.state = UserPreferences.showArtist.asState
        showTitleButton.state =  UserPreferences.showTitle.asState
        showPlayingIconButton.state = UserPreferences.showPlayingIcon.asState
        showSpotMenuIconButton.state = UserPreferences.showSpotMenuIcon.asState
    }
    
    func initButtonHovers(){
        showArtistButton.mouseEnteredFunc = hoverShowArtist
        showTitleButton.mouseEnteredFunc = hoverShowTitle
        showPlayingIconButton.mouseEnteredFunc = hoverShowPlayingIcon
        showSpotMenuIconButton.mouseEnteredFunc = hoverShowSpotMenuIcon
        showArtistButton.mouseExitedFunc = hoverAway
    }
    
    @IBAction func toggleShowArtist(_ sender: Any) {
        UserPreferences.showArtist = showArtistButton.state.asBool
        postUpdateNotification()
    }
    
    @IBAction func toggleShowTitle(_ sender: Any) {
        UserPreferences.showTitle = showTitleButton.state.asBool
        postUpdateNotification()
    }
    
    @IBAction func toggleShowPlayingIcon(_ sender: Any) {
        UserPreferences.showPlayingIcon = showPlayingIconButton.state.asBool
        postUpdateNotification()
    }
    
    @IBAction func toggleShowSpotMenuIcon(_ sender: Any) {
        UserPreferences.showSpotMenuIcon = showSpotMenuIconButton.state.asBool
        postUpdateNotification()
    }
    
    func postUpdateNotification(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: InternalNotification.key), object: self)
    }
    
}

extension GeneralPreferencesVC {
    func hoverShowArtist() {
       moreInformation.stringValue = "When checked the Artist will be shown in the menu bar"
    }
    
    func hoverShowTitle() {
        moreInformation.stringValue = "When checked the Title will be shown in the menu bar"
    }
    
    func hoverShowPlayingIcon() {
        moreInformation.stringValue = "When checked the playing icon (♫) will be shown in the menu bar if the music is playing"
    }
    
    func hoverShowSpotMenuIcon() {
        moreInformation.stringValue = "When checked the SpotMenu icon will be shown in the menubar\n\nNote\nIf there is now music information to be shown the SpotMenu icon will be visible"
    }
    
    func hoverAway() {
        moreInformation.stringValue = defaultMoreInformationText
    }
}


