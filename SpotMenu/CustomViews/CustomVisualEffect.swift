//
//  CustomVisualEffect.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 02. 21..
//  Copyright © 2017. KM. All rights reserved.
//

import AppKit
import Foundation

class CustomVisualEffect: NSVisualEffectView {

    private enum FadeType {
        case fadeIn, fadeOut
    }

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
        fade()
    }

    // MARK: - Mouse events

    override func mouseEntered(with _: NSEvent) {
        fade(type: .fadeIn)
    }

    override func mouseExited(with _: NSEvent) {
        fade()
    }

    // MARK: - Private helper methods

    private func fade(type: FadeType = .fadeOut) {

        let from = type == .fadeOut ? 1 : 0
        let to = 1 - from

        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.fromValue = from
        fadeAnim.toValue = to
        fadeAnim.duration = 0.1
        layer?.add(fadeAnim, forKey: "opacity")

        alphaValue = CGFloat(to)
    }
}
