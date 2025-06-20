import AppKit

final class MenuBuilder {
    static func build(delegate: AppDelegate) -> NSMenu {
        let menu = NSMenu()

        menu.addItem(
            NSMenuItem(
                title: "Refresh",
                action: #selector(delegate.refreshAction),
                keyEquivalent: "r"
            )
        )
        menu.addItem(
            NSMenuItem(
                title: "Preferences…",
                action: #selector(delegate.preferencesAction),
                keyEquivalent: ","
            )
        )
        menu.addItem(.separator())
        menu.addItem(
            NSMenuItem(
                title: "Quit",
                action: #selector(delegate.quitApp),
                keyEquivalent: "q"
            )
        )

        return menu
    }
}
