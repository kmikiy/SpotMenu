import Combine
import Foundation

class PlayerPreferencesModel: ObservableObject {
    @Published var preferredPlayer: PreferredPlayer {
        didSet {
            UserDefaults.standard.set(
                preferredPlayer.rawValue,
                forKey: "preferredPlayer"
            )
        }
    }

    init() {
        let rawValue =
            UserDefaults.standard.string(forKey: "preferredPlayer")
            ?? "automatic"
        preferredPlayer = PreferredPlayer(rawValue: rawValue) ?? .automatic
    }
}
