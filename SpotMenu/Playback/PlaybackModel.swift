import Combine
import SwiftUI

extension Notification.Name {
    static let contentModelDidUpdate = Notification.Name(
        "PlaybackModelDidUpdate"
    )
}

enum PlayerType {
    case spotify
    case appleMusic
}

enum PreferredPlayer: String, CaseIterable, Identifiable {
    case automatic
    case spotify
    case appleMusic

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .automatic: return "Automatic"
        case .spotify: return "Spotify"
        case .appleMusic: return "Apple Music"
        }
    }
}

struct PlaybackInfo {
    let artist: String
    let title: String
    let isPlaying: Bool
    let imageURL: URL?
    let totalTime: Double
    let currentTime: Double
    let image: Image?
}

protocol MusicPlayerController {
    func fetchNowPlayingInfo() -> PlaybackInfo?
    func togglePlayPause()
    func skipForward()
    func skipBack()
    func updatePlaybackPosition(to seconds: Double)
    func openApp()
}

class PlaybackModel: ObservableObject {
    @Published var imageURL: URL?
    @Published var image: Image? = nil
    @Published var isPlaying: Bool = false
    @Published var title: String = ""
    @Published var artist: String = ""
    @Published var totalTime: Double = 1
    @Published var currentTime: Double = 0
    @Published var playerType: PlayerType

    private let preferences: PlayerPreferencesModel
    private var controller: MusicPlayerController
    private var timer: Timer?

    private var cancellable: AnyCancellable?

    var playerIconName: String {
        return playerType == .appleMusic ? "AppleMusicIcon" : "SpotifyIcon"
    }

    init(preferences: PlayerPreferencesModel) {

        self.preferences = preferences

        let (controller, type) = Self.selectController(
            for: preferences.preferredMusicApp
        )
        self.controller = controller
        self.playerType = type

        fetchInfo()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            self.fetchInfo()
        }

        cancellable = preferences.$preferredMusicApp
            .removeDuplicates()
            .sink { [weak self] newPreference in
                self?.switchPlayer(to: newPreference)
            }
    }

    func switchPlayer(to newPreference: PreferredPlayer) {
        let (newController, newType) = Self.selectController(for: newPreference)
        controller = newController
        playerType = newType
        fetchInfo()
    }

    private static func selectController(for preference: PreferredPlayer) -> (
        MusicPlayerController, PlayerType
    ) {
        let spotifyInstalled = Self.isAppInstalled("com.spotify.client")
        let appleMusicInstalled = Self.isAppInstalled("com.apple.Music")
        let spotifyRunning = Self.isAppRunning("com.spotify.client")
        let appleMusicRunning = Self.isAppRunning("com.apple.Music")

        switch preference {
        case .appleMusic:
            return (AppleMusicController(), .appleMusic)
        case .spotify:
            return (SpotifyController(), .spotify)
        case .automatic:
            if spotifyRunning {
                return (SpotifyController(), .spotify)
            } else if appleMusicRunning {
                return (AppleMusicController(), .appleMusic)
            } else if spotifyInstalled {
                return (SpotifyController(), .spotify)
            } else if appleMusicInstalled {
                return (AppleMusicController(), .appleMusic)
            } else {
                return (SpotifyController(), .spotify)
            }
        }
    }

    private static func isAppInstalled(_ bundleIdentifier: String) -> Bool {
        return NSWorkspace.shared.urlForApplication(
            withBundleIdentifier: bundleIdentifier
        ) != nil
    }

    private static func isAppRunning(_ bundleIdentifier: String) -> Bool {
        return NSRunningApplication.runningApplications(
            withBundleIdentifier: bundleIdentifier
        ).count > 0
    }

    func fetchInfo() {
        guard let info = controller.fetchNowPlayingInfo() else {
            reset()
            return
        }

        DispatchQueue.main.async {
            self.title = info.title
            self.artist = info.artist
            self.isPlaying = info.isPlaying
            self.imageURL = info.imageURL
            self.totalTime = info.totalTime
            self.currentTime = info.currentTime
            self.image = info.image

            NotificationCenter.default.post(
                name: .contentModelDidUpdate,
                object: nil
            )
        }
    }

    func togglePlayPause() {
        controller.togglePlayPause()
        self.isPlaying = !self.isPlaying
        delayedFetch()
    }

    func skipForward() {
        controller.skipForward()
        delayedFetch()
    }

    func skipBack() {
        controller.skipBack()
        delayedFetch()
    }

    func updatePlaybackPosition(to seconds: Double) {
        controller.updatePlaybackPosition(to: seconds)
        self.currentTime = seconds
    }

    func openMusicApp() {
        controller.openApp()
    }

    private func delayedFetch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.fetchInfo()
        }
    }

    private func reset() {
        DispatchQueue.main.async {
            self.title = ""
            self.artist = ""
            self.isPlaying = false
            self.imageURL = nil
            self.currentTime = 0
            self.totalTime = 1
            self.image = nil
        }
    }
}

func runAppleScript(_ script: String) -> String? {
    var error: NSDictionary?
    if let scriptObject = NSAppleScript(source: script) {
        let output = scriptObject.executeAndReturnError(&error)
        return output.stringValue
    }
    return nil
}

func openApp(bundleIdentifier: String) {
    guard
        let url = NSWorkspace.shared.urlForApplication(
            withBundleIdentifier: bundleIdentifier
        )
    else {
        print("App with bundle ID \(bundleIdentifier) not found.")
        return
    }

    let config = NSWorkspace.OpenConfiguration()
    NSWorkspace.shared.openApplication(at: url, configuration: config) {
        app,
        error in
        if let error = error {
            print("Failed to open app: \(error.localizedDescription)")
        }
    }
}
