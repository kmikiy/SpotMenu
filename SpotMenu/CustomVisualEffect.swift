//
//  CustomVisualEffect.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 02. 21..
//  Copyright © 2017. KM. All rights reserved.
//

import Foundation
import AppKit

class CustomVisualEffect: NSVisualEffectView {
    var trackingArea:NSTrackingArea!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        // set tracking area
        let opts: NSTrackingAreaOptions = ([NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways])
        trackingArea = NSTrackingArea(rect: bounds, options: opts, owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
        
        self.alphaValue = 0
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        // set tracking area
        let opts: NSTrackingAreaOptions = ([NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways])
        trackingArea = NSTrackingArea(rect: bounds, options: opts, owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
        
        self.alphaValue = 0
    }
    
    deinit {
        self.removeTrackingArea(trackingArea)
    }
    
    // MARK: mouse events
    override func mouseEntered(with theEvent: NSEvent) {
        self.alphaValue = 1
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        self.alphaValue = 0
    }

}
