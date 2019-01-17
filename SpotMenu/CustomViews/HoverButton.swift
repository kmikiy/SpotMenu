//
//  HoverButton.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 05. 01..
//  Copyright © 2017. KM. All rights reserved.
//

import AppKit
import Foundation

final class HoverButton: NSButton {

    // MARK: - Properties

    private lazy var trackingArea: NSTrackingArea = self.createTrackingArea()

    var mouseEnteredFunc: (() -> Void)?

    var mouseExitedFunc: (() -> Void)?

    // MARK: - Lifecycle methods

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        // set tracking area
        addTrackingArea(trackingArea)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // set tracking area
        addTrackingArea(trackingArea)
    }

    deinit {
        removeTrackingArea(trackingArea)
    }

    // MARK: - Mouse methods

    override func mouseEntered(with _: NSEvent) {
        mouseEnteredFunc?()
    }

    override func mouseExited(with _: NSEvent) {
        mouseExitedFunc?()
    }
}
