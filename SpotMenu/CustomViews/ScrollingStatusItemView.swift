//
//  ScrollingStatusItemView.swift
//  SpotMenu
//
//  Created by Nicholas Bellucci on 11/12/18.
//  Copyright © 2018 KM. All rights reserved.
//

import Foundation
import Cocoa

class ScrollingStatusItemView: NSView {
    private enum Constants {
        static let itemLength: CGFloat = 200
        static let iconSize: CGFloat = 30
        static let widthConstraint: CGFloat = 170
        static let textViewLength: CGFloat = 150
        static let padding: CGFloat = 6
    }

    var icon: NSImage? {
        didSet {
            iconImageView.image = icon
        }
    }

    var text: String? {
        didSet {
            guard let text = text else { return }
            scrollingTextView.setup(string: text, width: 150, speed: 0.04)
        }
    }

    var hasImage: Bool {
        return iconImageView.image != nil
    }

    private lazy var iconImageView: NSImageView = {
        let imageView = NSImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image?.isTemplate = true
        return imageView
    }()

    private lazy var scrollingTextView: ScrollingTextView = {
        let scrollingText = ScrollingTextView()
        scrollingText.translatesAutoresizingMaskIntoConstraints = false
        return scrollingText
    }()

    required init() {
        super.init(frame: .zero)
        loadSubviews()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func mouseDown(with event: NSEvent) {
        scrollingTextView.textColor = .red
        super.mouseDown(with: event)
        scrollingTextView.textColor = .white
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
            scrollingTextView.leftAnchor.constraint(equalTo: leftAnchor, constant: 30)])

        NSLayoutConstraint.activate([
            iconImageView.rightAnchor.constraint(equalTo: scrollingTextView.leftAnchor),
            iconImageView.topAnchor.constraint(equalTo: topAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 30)])
    }
}
