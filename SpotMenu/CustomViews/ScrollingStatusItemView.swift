//
//  ScrollingStatusItemView.swift
//  SpotMenu
//
//  Created by Nicholas Bellucci on 11/12/18.
//  Copyright © 2018 KM. All rights reserved.
//

import Foundation
import Cocoa

typealias StatusItemLengthUpdate = (CGFloat) -> ()

class ScrollingStatusItemView: NSView {
    private enum Constants {
        static let padding: CGFloat = 6
        static let iconSize: CGFloat = 30
        static let defaultWidth: CGFloat = 150
        static let defaultSpeed: Double = 0.04
    }

    var lengthHandler: StatusItemLengthUpdate?

    var icon: NSImage? {
        didSet {
            iconImageView.image = icon
            iconWidthConstraint.constant = icon != nil ? Constants.iconSize : 0
        }
    }

    var text: String? {
        didSet {
            guard let text = text else { return }
            scrollingTextView.setup(string: text)

            if iconImageView.image == nil {
                lengthHandler?(scrollingTextView.stringSize.width + Constants.padding)
            } else {
                lengthHandler?(scrollingTextView.stringSize.width + Constants.iconSize + Constants.padding)
            }
        }
    }

    var speed: Double? {
        didSet {
            guard let speed = speed else { return }
            scrollingTextView.speed = speed
        }
    }

    var hasImage: Bool {
        return iconImageView.image != nil
    }

    private var length: CGFloat? {
        didSet {
            guard let length = length else { return }
            scrollingTextView.length = length
        }
    }

    private lazy var iconImageView: NSImageView = {
        let imageView = NSImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image?.isTemplate = true
        return imageView
    }()

    private lazy var scrollingTextView: ScrollingTextView = {
        let view = ScrollingTextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var iconWidthConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint(item: iconImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 0, constant: 0)
        constraint.isActive = true
        constraint.constant = 0
        return constraint
    }()

    required init() {
        super.init(frame: .zero)
        loadSubviews()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func mouseDown(with event: NSEvent) {
        clicked(true)
        super.mouseDown(with: event)
        clicked(false)
    }

    override func rightMouseDown(with event: NSEvent) {
        clicked(true)
        super.rightMouseDown(with: event)
        clicked(false)
    }

    override func layout() {
        super.layout()
        length = scrollingTextView.frame.width
    }
}

private extension ScrollingStatusItemView {
    func loadSubviews() {
        addSubview(iconImageView)
        addSubview(scrollingTextView)

        NSLayoutConstraint.activate([
            scrollingTextView.rightAnchor.constraint(equalTo: rightAnchor),
            scrollingTextView.topAnchor.constraint(equalTo: topAnchor),
            scrollingTextView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollingTextView.leftAnchor.constraint(equalTo: iconImageView.rightAnchor)])

        NSLayoutConstraint.activate([
            iconImageView.leftAnchor.constraint(equalTo: leftAnchor),
            iconImageView.topAnchor.constraint(equalTo: topAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }

    func clicked(_ bool: Bool) {
        if bool {
            iconImageView.image?.tint(color: .white)
            scrollingTextView.textColor = .white
        } else {
            iconImageView.image?.isTemplate = true
            scrollingTextView.textColor = .headerTextColor
        }
    }
}

extension NSImage {
    func tint(color: NSColor) {
        let imageRect = NSRect(origin: NSZeroPoint, size: size)

        isTemplate = false
        lockFocus()
        color.set()
        imageRect.fill(using: .sourceAtop)
        unlockFocus()
    }
}
