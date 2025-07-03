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
    }
}
