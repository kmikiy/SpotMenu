import SwiftUI

final class StatusItemConfigurator {
    static func configure(
        statusItem: NSStatusItem,
        statusItemModel: StatusItemModel,
        visualPreferencesModel: VisualPreferencesModel,
        toggleAction: Selector,
        target: AnyObject
    ) {
        let view = StatusItemView(
            model: statusItemModel,
            preferencesModel: visualPreferencesModel
        )
        let hostingView = NSHostingView(rootView: view)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.layout()

        if let button = statusItem.button {
            button.addSubview(hostingView)
            NSLayoutConstraint.activate([
                hostingView.centerXAnchor.constraint(
                    equalTo: button.centerXAnchor
                ),
                hostingView.centerYAnchor.constraint(
                    equalTo: button.centerYAnchor
                ),
            ])
            button.action = toggleAction
            button.target = target
        }
    }

    static func updateWidth(statusItem: NSStatusItem, maxWidth: CGFloat) {
        guard
            let hostingView = statusItem.button?.subviews.compactMap({
                $0 as? NSHostingView<StatusItemView>
            }).first
        else {
            return
        }
        hostingView.layout()
        statusItem.length = min(
            hostingView.intrinsicContentSize.width,
            maxWidth
        )
    }
}
