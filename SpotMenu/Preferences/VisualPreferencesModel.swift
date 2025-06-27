import Combine
import Foundation

class VisualPreferencesModel: ObservableObject {
    @Published var showArtist: Bool {
        didSet { UserDefaults.standard.set(showArtist, forKey: "showArtist") }
    }
    @Published var showTitle: Bool {
        didSet {
            UserDefaults.standard.set(showTitle, forKey: "showTitle")
        }
    }
    @Published var showIsPlayingIcon: Bool {
        didSet {
            UserDefaults.standard.set(
                showIsPlayingIcon,
                forKey: "showIsPlayingIcon"
            )
        }
    }
    @Published var showAppIcon: Bool {
        didSet { UserDefaults.standard.set(showAppIcon, forKey: "showAppIcon") }
    }
    @Published var compactView: Bool {
        didSet { UserDefaults.standard.set(compactView, forKey: "compactView") }
    }
    @Published var maxStatusItemWidth: CGFloat {
        didSet {
            UserDefaults.standard.set(
                maxStatusItemWidth,
                forKey: "maxStatusItemWidth"
            )
        }
    }
    @Published var enableScrollingText: Bool {
        didSet {
            UserDefaults.standard.set(
                enableScrollingText,
                forKey: "enableScrollingText"
            )
        }
    }
    @Published var fontSizeOption: FontSizeOption {
        didSet {
            UserDefaults.standard.set(fontSizeOption.rawValue, forKey: "fontSizeOption")
        }
    }
    @Published var scrollSpeed: ScrollSpeed {
        didSet {
            UserDefaults.standard.set(scrollSpeed.rawValue, forKey: "scrollSpeed")
        }
    }



    var isTextVisible: Bool {
        return showArtist || showTitle
    }

    init() {
        let defaults = UserDefaults.standard

        showArtist = defaults.object(forKey: "showArtist") as? Bool ?? true
        showTitle =
            defaults.object(forKey: "showTitle") as? Bool ?? true
        showIsPlayingIcon =
            defaults.object(forKey: "showIsPlayingIcon") as? Bool ?? true
        showAppIcon = defaults.object(forKey: "showAppIcon") as? Bool ?? true
        compactView = defaults.object(forKey: "compactView") as? Bool ?? true
        maxStatusItemWidth =
            defaults.object(forKey: "maxStatusItemWidth") as? CGFloat ?? 150
        enableScrollingText =
            defaults.object(forKey: "enableScrollingText") as? Bool ?? false
        let rawValue = defaults.string(forKey: "fontSizeOption") ?? "small"
        fontSizeOption = FontSizeOption(rawValue: rawValue) ?? .small
        scrollSpeed = ScrollSpeed(rawValue: defaults.string(forKey: "scrollSpeed") ?? "") ?? .normal
    }
}
