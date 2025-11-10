import Combine
import Foundation
import SwiftUI

enum MenuBarFontWeight: String, CaseIterable {
    case ultraLight = "ultraLight"
    case thin = "thin"
    case light = "light"
    case regular = "regular"
    case medium = "medium"
    case semibold = "semibold"
    case bold = "bold"
    case heavy = "heavy"
    case black = "black"

    var fontWeight: Font.Weight {
        switch self {
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        }
    }
}

class MenuBarPreferencesModel: ObservableObject {
    @Published var showArtist: Bool {
        didSet {
            UserDefaults.standard.set(showArtist, forKey: "menuBar.showArtist")
        }
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
    @Published var showIsLikedIcon: Bool {
        didSet {
            UserDefaults.standard.set(
                showIsLikedIcon,
                forKey: "menuBar.showIsLikedIcon"
            )
        }
    }
    @Published var showAppIcon: Bool {
        didSet {
            UserDefaults.standard.set(
                showAppIcon,
                forKey: "menuBar.showAppIcon"
            )
        }
    }
    @Published var compactView: Bool {
        didSet {
            UserDefaults.standard.set(
                compactView,
                forKey: "menuBar.compactView"
            )
        }
    }
    @Published var maxStatusItemWidth: CGFloat {
        didSet {
            UserDefaults.standard.set(
                maxStatusItemWidth,
                forKey: "menuBar.maxStatusItemWidth"
            )
        }
    }
    @Published var hideArtistWhenPaused: Bool {
        didSet {
            UserDefaults.standard.set(
                hideArtistWhenPaused,
                forKey: "menuBar.hideArtistWhenPaused"
            )
        }
    }
    @Published var hideTitleWhenPaused: Bool {
        didSet {
            UserDefaults.standard.set(
                hideTitleWhenPaused,
                forKey: "menuBar.hideTitleWhenPaused"
            )
        }
    }
    @Published var fontWeightCompactTop: MenuBarFontWeight {
        didSet {
            UserDefaults.standard.set(
                fontWeightCompactTop.rawValue,
                forKey: "menuBar.fontWeightCompactTop"
            )
        }
    }
    @Published var fontWeightCompactBottom: MenuBarFontWeight {
        didSet {
            UserDefaults.standard.set(
                fontWeightCompactBottom.rawValue,
                forKey: "menuBar.fontWeightCompactBottom"
            )
        }
    }
    @Published var fontWeightNormal: MenuBarFontWeight {
        didSet {
            UserDefaults.standard.set(
                fontWeightNormal.rawValue,
                forKey: "menuBar.fontWeightNormal"
            )
        }
    }

    var isTextVisible: Bool {
        return showArtist || showTitle
    }

    init() {
        let defaults = UserDefaults.standard

        showArtist =
            defaults.object(forKey: "menuBar.showArtist") as? Bool ?? true
        showTitle =
            defaults.object(forKey: "menuBar.showTitle") as? Bool ?? true
        showIsPlayingIcon =
            defaults.object(forKey: "menuBar.showIsPlayingIcon") as? Bool
            ?? true
        showIsLikedIcon =
            defaults.object(forKey: "menuBar.showIsLikedIcon") as? Bool
            ?? true
        showAppIcon =
            defaults.object(forKey: "menuBar.showAppIcon") as? Bool ?? true
        compactView =
            defaults.object(forKey: "menuBar.compactView") as? Bool ?? true
        maxStatusItemWidth =
            defaults.object(forKey: "menuBar.maxStatusItemWidth") as? CGFloat
            ?? 150
        hideArtistWhenPaused =
            defaults.object(forKey: "menuBar.hideArtistWhenPaused") as? Bool
            ?? false
        hideTitleWhenPaused =
            defaults.object(forKey: "menuBar.hideTitleWhenPaused") as? Bool
            ?? false

        fontWeightCompactTop = MenuBarFontWeight(
            rawValue: defaults.string(forKey: "menuBar.fontWeightCompactTop") ?? "medium"
        ) ?? .medium
        fontWeightCompactBottom = MenuBarFontWeight(
            rawValue: defaults.string(forKey: "menuBar.fontWeightCompactBottom") ?? "medium"
        ) ?? .medium
        fontWeightNormal = MenuBarFontWeight(
            rawValue: defaults.string(forKey: "menuBar.fontWeightNormal") ?? "medium"
        ) ?? .medium
    }
}
