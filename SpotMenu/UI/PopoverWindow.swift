import Cocoa
import SwiftUI

class PopoverWindow: NSPanel {
    init<Content: View>(rootView: Content) {
        let hostingView = NSHostingView(rootView: rootView)
        let contentRect = NSRect(x: 0, y: 0, width: 300, height: 300)

        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: true
        )

        self.isReleasedWhenClosed = false
        self.level = .floating
        self.collectionBehavior = [.transient, .canJoinAllSpaces]
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = true
        self.ignoresMouseEvents = false
        self.becomesKeyOnlyIfNeeded = true
        hostingView.layer?.masksToBounds = true

        self.contentView = hostingView
    }

    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return false
    }
}
