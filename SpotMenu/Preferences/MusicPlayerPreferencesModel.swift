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
            defaults.object(forKey: "playback.likingEnabled") as? Bool ?? true

    }
}
