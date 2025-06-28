import Combine
import Foundation
import SwiftUI

class PlayerPreferencesModel: ObservableObject {
    @Published var preferredMusicApp: PreferredPlayer {
        didSet {
            UserDefaults.standard.set(
                preferredMusicApp.rawValue,
                forKey: "playback.preferredMusicApp"
            )
        }
    }

    @Published var hoverTintColor: NSColor {
        didSet {
            if let data = try? NSKeyedArchiver.archivedData(
                withRootObject: hoverTintColor,
                requiringSecureCoding: false
            ) {
                UserDefaults.standard.set(
                    data,
                    forKey: "playback.hoverTintColor"
                )
            }
        }
    }

    @Published var blurIntensity: Double {
        didSet {
            UserDefaults.standard.set(
                blurIntensity,
                forKey: "playback.blurIntensity"
            )
        }
    }

    @Published var foregroundColor: ForegroundColorOption {
        didSet {
            UserDefaults.standard.set(
                foregroundColor.rawValue,
                forKey: "playback.foregroundColor"
            )
        }
    }

    enum ForegroundColorOption: String, CaseIterable, Identifiable {
        case white
        case black

        var id: String { self.rawValue }

        var color: Color {
            self == .white ? .white : .black
        }
    }

    enum AppearanceMode: String, CaseIterable, Identifiable {
        case system, light, dark
        var id: String { self.rawValue }
    }

    init() {
        let defaults = UserDefaults.standard

        if let rawValue = defaults.string(forKey: "playback.preferredMusicApp"),
            let app = PreferredPlayer(rawValue: rawValue)
        {
            preferredMusicApp = app
        } else {
            preferredMusicApp = .automatic
        }

        if let data = defaults.data(forKey: "playback.hoverTintColor"),
            let color = try? NSKeyedUnarchiver.unarchivedObject(
                ofClass: NSColor.self,
                from: data
            )
        {
            hoverTintColor = color
        } else {
            hoverTintColor = .systemBlue
        }

        let storedBlur =
            defaults.object(forKey: "playback.blurIntensity") as? Double
        blurIntensity = storedBlur ?? 0.5

        if let rawValue = defaults.string(forKey: "playback.foregroundColor"),
            let fg = ForegroundColorOption(rawValue: rawValue)
        {
            foregroundColor = fg
        } else {
            foregroundColor = .white
        }
    }
}
