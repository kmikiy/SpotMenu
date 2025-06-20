import Combine
import Foundation

class VisualPreferencesModel: ObservableObject {
    @Published var showArtist: Bool {
        didSet { UserDefaults.standard.set(showArtist, forKey: "showArtist") }
    }
    @Published var showSongTitle: Bool {
        didSet {
            UserDefaults.standard.set(showSongTitle, forKey: "showSongTitle")
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

    var showAppIconOnly: Bool {
        return !showArtist && !showSongTitle && !showIsPlayingIcon
    }

    var isTextVisible: Bool {
        return showArtist || showSongTitle
    }

    init() {
        let defaults = UserDefaults.standard

        showArtist = defaults.object(forKey: "showArtist") as? Bool ?? true
        showSongTitle =
            defaults.object(forKey: "showSongTitle") as? Bool ?? true
        showIsPlayingIcon =
            defaults.object(forKey: "showIsPlayingIcon") as? Bool ?? true
        compactView = defaults.object(forKey: "compactView") as? Bool ?? true
        maxStatusItemWidth =
            defaults.object(forKey: "maxStatusItemWidth") as? CGFloat ?? 150
    }
}
