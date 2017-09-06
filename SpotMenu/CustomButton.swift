//
//  CustomButton.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 06/09/16.
//  Copyright © 2016 KM. All rights reserved.
//

import Foundation
import AppKit

class CustomButton: NSButton {
    
    // MARK: - Properties
    
    private lazy var trackingArea: NSTrackingArea = self.createTrackingArea()
    
    // MARK: - Lifecycle methods
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    deinit {
        removeTrackingArea(trackingArea)
    }
    
    private func setup() {
        addTrackingArea(trackingArea)
        alphaValue = 0
    }
    
    // MARK: - Mouse events
    
    override func mouseEntered(with theEvent: NSEvent) {
        alphaValue = 1
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        alphaValue = 0
    }
}
