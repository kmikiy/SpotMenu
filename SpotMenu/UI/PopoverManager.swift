import SwiftUI

class PopoverManager {
    private var window: PopoverWindow

    init<Content: View>(contentView: Content) {
        self.window = PopoverWindow(rootView: contentView)
    }

    func toggle(relativeTo button: NSStatusBarButton?) {
        guard let button = button else { return }

        if window.isVisible {
            dismiss()
        } else {
            show(relativeTo: button)
        }
    }

    private func show(relativeTo button: NSStatusBarButton) {
        guard let buttonWindow = button.window,
            let screen = buttonWindow.screen
        else { return }

        let buttonFrame = buttonWindow.convertToScreen(
            button.convert(button.bounds, to: nil)
        )

        let popoverSize = window.frame.size

        let menuBarHeight = screen.frame.maxY - screen.visibleFrame.maxY
        let spacingBelowMenuBar: CGFloat = 6
        let totalOffset = menuBarHeight + spacingBelowMenuBar

        let popoverY = screen.frame.maxY - totalOffset - popoverSize.height
        let popoverX = buttonFrame.midX - popoverSize.width / 2

        window.setFrameOrigin(NSPoint(x: popoverX, y: popoverY))
        window.alphaValue = 0
        window.makeKeyAndOrderFront(nil)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            window.animator().alphaValue = 1
        }
    }

    func dismiss() {
        guard window.isVisible else { return }
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            window.animator().alphaValue = 0
        } completionHandler: {
            self.window.orderOut(nil)
            self.window.alphaValue = 1
        }
    }
}
