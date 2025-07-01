import Combine
import Foundation
import SwiftUI

class PlaybackAppearancePreferencesModel: ObservableObject {
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

    @Published var hoverTintOpacity: Double {
        didSet {
            UserDefaults.standard.set(
                hoverTintOpacity,
                forKey: "playback.hoverTintOpacity"
            )
        }
    }

    @Published var likingEnabled: Bool {
        didSet {
            UserDefaults.standard.set(
                likingEnabled,
                forKey: "playback.likingEnabled"
            )
        }
    }

    enum ForegroundColorOption: String, CaseIterable, Identifiable {
        case white, black
        var id: String { rawValue }
        var color: Color {
            self == .white ? .white : .black
        }
    }

    init() {
        let defaults = UserDefaults.standard

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

        blurIntensity =
            defaults.object(forKey: "playback.blurIntensity") as? Double ?? 0.5

        if let rawValue = defaults.string(forKey: "playback.foregroundColor"),
            let fg = ForegroundColorOption(rawValue: rawValue)
        {
            foregroundColor = fg
        } else {
            foregroundColor = .white
        }

        hoverTintOpacity =
            defaults.object(forKey: "playback.hoverTintOpacity") as? Double
            ?? 0.3
        likingEnabled =
            defaults.object(forKey: "playback.likingEnabled") as? Bool ?? true
    }
}
