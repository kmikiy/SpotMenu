import Combine
import Foundation

class MusicPlayerPreferencesModel: ObservableObject {
    @Published var preferredMusicApp: PreferredPlayer {
        didSet {
            UserDefaults.standard.set(
                preferredMusicApp.rawValue,
                forKey: "musicPlayer.preferredMusicApp"
            )
        }
    }

    @Published var likingEnabled: Bool {
        didSet {
            UserDefaults.standard.set(
                likingEnabled,
                forKey: "musicPlayer.likingEnabled"
            )
        }
    }

    @Published var spotifyClientID: String? {
        didSet {
            UserDefaults.standard.set(
                spotifyClientID,
                forKey: "spotify.clientID"
            )
        }
    }

    @Published var longFormTitleStyle: LongFormTitleStyle {
        didSet {
            UserDefaults.standard.set(
                longFormTitleStyle.rawValue,
                forKey: "spotify.longFormTitleStyle"
            )
        }
    }

    init() {
        let defaults = UserDefaults.standard

        if let rawValue = defaults.string(
            forKey: "musicPlayer.preferredMusicApp"
        ),
            let app = PreferredPlayer(rawValue: rawValue)
        {
            preferredMusicApp = app
        } else {
            preferredMusicApp = .automatic
        }

        likingEnabled =
            defaults.object(forKey: "musicPlayer.likingEnabled") as? Bool ?? true

        spotifyClientID = defaults.string(forKey: "spotify.clientID")

        if let storedRaw = defaults.string(
            forKey: "spotify.longFormTitleStyle"
        ), let storedStyle = LongFormTitleStyle(rawValue: storedRaw) {
            longFormTitleStyle = storedStyle
        } else if let legacyAppend =
            defaults.object(
                forKey: "spotify.showAudiobookChapterInTitle"
            ) as? Bool
        {
            longFormTitleStyle =
                legacyAppend ? .titleAndSegment : .titleOnly
        } else {
            longFormTitleStyle = .titleOnly
        }
    }
}
