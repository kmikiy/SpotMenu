//
//  HoverButton.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 05. 01..
//  Copyright © 2017. KM. All rights reserved.
//

import Foundation

import Foundation
import AppKit

class HoverButton: NSButton {
    var trackingArea:NSTrackingArea!
    var mouseEnteredFunc: (()->Void)?
    var mouseExitedFunc: (()->Void)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        // set tracking area
        let opts: NSTrackingAreaOptions = ([NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways])
        trackingArea = NSTrackingArea(rect: bounds, options: opts, owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        // set tracking area
        let opts: NSTrackingAreaOptions = ([NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways])
        trackingArea = NSTrackingArea(rect: bounds, options: opts, owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
    }
    
    deinit {
        self.removeTrackingArea(trackingArea)
    }
    
    // MARK: mouse events
    override func mouseEntered(with theEvent: NSEvent) {
        mouseEnteredFunc?()
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        mouseExitedFunc?()
    }
}
