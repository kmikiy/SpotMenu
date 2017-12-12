//
//  AboutPreferencesVC.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 12. 03..
//  Copyright © 2017. KM. All rights reserved.
//

import Cocoa

class AboutPreferencesVC: NSViewController {

    @IBOutlet weak var scrollView: NSScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        scrollView.flashScrollers()
    }
}
