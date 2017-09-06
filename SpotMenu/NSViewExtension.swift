//
//  NSViewExtension.swift
//  SpotMenu
//
//  Created by Daniel Tombor on 2017. 09. 06..
//  Copyright © 2017. KM. All rights reserved.
//

import AppKit

extension NSView {
    
    func createTrackingArea() -> NSTrackingArea {
        
        let opts: NSTrackingAreaOptions = ([
            NSTrackingAreaOptions.mouseEnteredAndExited,
            NSTrackingAreaOptions.activeAlways])
        
        return NSTrackingArea(
            rect: bounds,
            options: opts,
            owner: self,
            userInfo: nil)
    }
    
}
