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
    
    @IBOutlet weak var showArtistButton: NSButton!
    @IBOutlet weak var showTitleButton: NSButton!
    @IBOutlet weak var showPlayingIconButton: NSButton!
    @IBOutlet weak var showSpotMenuIconButton: NSButton!
    
    
    override func viewWillAppear() {
        initButtonStates()
    }
    
    func initButtonStates(){
        showArtistButton.state = UserPreferences.showArtist.asState
        showTitleButton.state =  UserPreferences.showTitle.asState
        showPlayingIconButton.state = UserPreferences.showPlayingIcon.asState
        showSpotMenuIconButton.state = UserPreferences.showSpotMenuIcon.asState
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


