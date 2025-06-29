import Combine
import Foundation

class MenuBarPreferencesModel: ObservableObject {
    @Published var showArtist: Bool {
        didSet { UserDefaults.standard.set(showArtist, forKey: "menuBar.showArtist") }
    }
    @Published var showTitle: Bool {
        didSet {
            UserDefaults.standard.set(showTitle, forKey: "menuBar.showTitle")
        }
    }
    @Published var showIsPlayingIcon: Bool {
        didSet {
            UserDefaults.standard.set(
                showIsPlayingIcon,
                forKey: "menuBar.showIsPlayingIcon"
            )
        }
    }
    @Published var showAppIcon: Bool {
        didSet { UserDefaults.standard.set(showAppIcon, forKey: "menuBar.showAppIcon") }
    }
    @Published var compactView: Bool {
        didSet { UserDefaults.standard.set(compactView, forKey: "menuBar.compactView") }
    }
    @Published var maxStatusItemWidth: CGFloat {
        didSet {
            UserDefaults.standard.set(
                maxStatusItemWidth,
                forKey: "menuBar.maxStatusItemWidth"
            )
        }
    }

    var isTextVisible: Bool {
        return showArtist || showTitle
    }

    init() {
        let defaults = UserDefaults.standard

        showArtist = defaults.object(forKey: "menuBar.showArtist") as? Bool ?? true
        showTitle =
            defaults.object(forKey: "menuBar.showTitle") as? Bool ?? true
        showIsPlayingIcon =
            defaults.object(forKey: "menuBar.showIsPlayingIcon") as? Bool ?? true
        showAppIcon = defaults.object(forKey: "menuBar.showAppIcon") as? Bool ?? true
        compactView = defaults.object(forKey: "menuBar.compactView") as? Bool ?? true
        maxStatusItemWidth =
            defaults.object(forKey: "menuBar.maxStatusItemWidth") as? CGFloat ?? 150
    }
}
