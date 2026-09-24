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
    case cider
}

enum LongFormTitleStyle: String, CaseIterable, Identifiable {
    case titleOnly
    case segmentOnly
    case titleAndSegment

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .titleOnly: return "Title Only"
        case .segmentOnly: return "Chapter/Episode Only"
        case .titleAndSegment: return "Title + Chapter/Episode"
        }
    }
}

enum PreferredPlayer: String, CaseIterable, Identifiable {
    case automatic
    case spotify
    case appleMusic
    case cider

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .automatic: return "Automatic"
        case .spotify: return "Spotify"
        case .appleMusic: return "Apple Music"
        case .cider: return "Cider"
        }
    }
}

enum LongFormKind {
    case audiobook
    case podcastEpisode
}

struct LongFormInfo {
    let kind: LongFormKind
    let title: String      // book or show title
    let authors: [String]  // authors or publisher
    let segmentTitle: String? // chapter or episode title
}

struct PlaybackInfo {
    let artist: String
    let title: String
    let isPlaying: Bool
    let imageURL: URL?
    let totalTime: Double
    let currentTime: Double
    let image: Image?
    let isLiked: Bool?
    let longFormInfo: LongFormInfo?
}

protocol MusicPlayerController {
    func fetchNowPlayingInfo() -> PlaybackInfo?
    func togglePlayPause()
    func skipForward()
    func skipBack()
    func updatePlaybackPosition(to seconds: Double)
    func openApp()
    func toggleLiked()
    func likeTrack()
    func unlikeTrack()
}

@MainActor
class PlaybackModel: ObservableObject {
    @Published var imageURL: URL?
    @Published var image: Image? = nil
    @Published var isPlaying: Bool = false
    @Published var title: String = ""
    @Published var artist: String = ""
    @Published var totalTime: Double = 1
    @Published var currentTime: Double = 0
    @Published var playerType: PlayerType
    @Published var isLiked: Bool? = nil
    @Published var longFormInfo: LongFormInfo? = nil

    private let preferences: MusicPlayerPreferencesModel
    private var controller: MusicPlayerController?
    private var timer: Timer?
    let cider: CiderSession

    private var cancellable: AnyCancellable?

    var playerIcon: Image {
        switch playerType {
        case .appleMusic: return Image("AppleMusicIcon")
        case .spotify: return Image("SpotifyIcon")
        case .cider: return Image(systemName: "c.circle.fill")
        }
    }

    var isLikingImplemented: Bool {
        return playerType == .spotify
    }

    var canSeek: Bool { playerType != .cider }

    init(preferences: MusicPlayerPreferencesModel) {
        self.preferences = preferences
        self.cider = CiderSession(preferences: preferences)

        let (controller, type) = Self.selectController(
            for: preferences.preferredMusicApp,
            preferences: preferences
        )
        self.controller = controller
        self.playerType = type

        cider.onPlayback = { [weak self] info, trackChanged in
            guard let self, self.playerType == .cider else { return }
            self.apply(info, trackChanged: trackChanged)
        }
        startSelectedPlayer()

        cancellable = preferences.$preferredMusicApp
            .removeDuplicates()
            .sink { [weak self] newPreference in
                self?.switchPlayer(to: newPreference)
            }
    }

    func switchPlayer(to newPreference: PreferredPlayer) {
        timer?.invalidate()
        timer = nil
        cider.stop()
        let (newController, newType) = Self.selectController(
            for: newPreference,
            preferences: preferences
        )
        controller = newController
        playerType = newType
        startSelectedPlayer()
    }

    private func startSelectedPlayer() {
        if playerType == .cider {
            reset()
            cider.start()
        } else {
            fetchInfo()
            timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
                Task { @MainActor in self?.fetchInfo() }
            }
        }
    }

    private static func selectController(
        for preference: PreferredPlayer,
        preferences: MusicPlayerPreferencesModel
    ) -> (
        MusicPlayerController?, PlayerType
    ) {
        let spotifyInstalled = isAppInstalled("com.spotify.client")
        let appleMusicInstalled = isAppInstalled("com.apple.Music")
        let ciderInstalled = isAppInstalled("sh.cider.genten.mac")
        let spotifyRunning = isAppRunning("com.spotify.client")
        let appleMusicRunning = isAppRunning("com.apple.Music")
        let ciderRunning = isAppRunning("sh.cider.genten.mac")

        switch preference {
        case .appleMusic:
            return (AppleMusicController(), .appleMusic)
        case .spotify:
            return (SpotifyController(preferences: preferences), .spotify)
        case .cider:
            return (nil, .cider)
        case .automatic:
            if spotifyRunning {
                return (SpotifyController(preferences: preferences), .spotify)
            } else if appleMusicRunning {
                return (AppleMusicController(), .appleMusic)
            } else if ciderRunning {
                return (nil, .cider)
            } else if spotifyInstalled {
                return (SpotifyController(preferences: preferences), .spotify)
            } else if appleMusicInstalled {
                return (AppleMusicController(), .appleMusic)
            } else if ciderInstalled {
                return (nil, .cider)
            } else {
                return (SpotifyController(preferences: preferences), .spotify)
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
        if playerType == .cider {
            cider.refresh()
            return
        }
        guard let info = controller?.fetchNowPlayingInfo() else {
            reset()
            return
        }

        apply(info)
    }

    private func apply(_ info: PlaybackInfo?, trackChanged: Bool = true) {
        guard let info else { reset(); return }
        let displayText = computeDisplayText(from: info)

        title = displayText.title
        artist = displayText.artist
        isPlaying = info.isPlaying
        if trackChanged { imageURL = info.imageURL }
        totalTime = info.totalTime
        currentTime = info.currentTime
        image = info.image
        isLiked = info.isLiked
        longFormInfo = info.longFormInfo
        notifyModelUpdate()
    }

    func togglePlayPause() {
        if playerType == .cider { cider.control(.toggle); return }
        // Execute the command first
        controller?.togglePlayPause()
        
        // Small delay to allow the music player to process, then update UI
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.isPlaying.toggle()
            self.notifyModelUpdate()
        }
        
        delayedFetch()
    }

    func skipForward() {
        if playerType == .cider { cider.control(.next); return }
        controller?.skipForward()
        delayedFetch()
    }

    func skipBack() {
        if playerType == .cider { cider.control(.previous); return }
        controller?.skipBack()
        delayedFetch()
    }

    func toggleLiked() {
        guard isLikingImplemented else { return }
        let previousLikeStatus = self.isLiked

        // Immediately update like status for UI responsiveness
        if let previous = previousLikeStatus {
            isLiked = !previous
        }
        
        // Send notification to update status bar immediately
        notifyModelUpdate()

        controller?.toggleLiked()
        delayedFetch()
    }

    func likeTrack() {
        guard isLikingImplemented else { return }
        // Immediately update like status for UI responsiveness
        isLiked = true
        
        // Send notification to update status bar immediately
        notifyModelUpdate()
        
        controller?.likeTrack()
    }

    func unlikeTrack() {
        guard isLikingImplemented else { return }
        // Immediately update like status for UI responsiveness
        isLiked = false
        
        // Send notification to update status bar immediately
        notifyModelUpdate()
        
        controller?.unlikeTrack()
    }

    func updatePlaybackPosition(to seconds: Double) {
        guard canSeek else { return }
        controller?.updatePlaybackPosition(to: seconds)
        self.currentTime = seconds
    }

    func openMusicApp() {
        if playerType == .cider {
            openApp(bundleIdentifier: "sh.cider.genten.mac")
            return
        }
        controller?.openApp()
    }

    private func delayedFetch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.fetchInfo()
        }
    }
    
    private func notifyModelUpdate() {
        NotificationCenter.default.post(
            name: .contentModelDidUpdate,
            object: nil
        )
    }

    private func reset() {
        title = ""
        artist = ""
        isPlaying = false
        imageURL = nil
        currentTime = 0
        totalTime = 1
        image = nil
        longFormInfo = nil
        isLiked = nil
        notifyModelUpdate()
    }

    private func computeDisplayText(from info: PlaybackInfo)
        -> (artist: String, title: String)
    {
        guard let longFormInfo = info.longFormInfo else {
            return (info.artist, info.title)
        }

        let authorText = longFormInfo.authors.joined(separator: ", ")
        let baseTitle =
            longFormInfo.title.isEmpty ? info.title : longFormInfo.title
        let segmentTitle = longFormInfo.segmentTitle?.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let titleText: String
        switch preferences.longFormTitleStyle {
        case .titleOnly:
            titleText = baseTitle
        case .segmentOnly:
            titleText = segmentTitle?.isEmpty == false ? segmentTitle!
                : baseTitle
        case .titleAndSegment:
            if let segment = segmentTitle,
                !segment.isEmpty,
                segment.caseInsensitiveCompare(baseTitle) != .orderedSame
            {
                titleText = "\(baseTitle) — \(segment)"
            } else {
                titleText = baseTitle
            }
        }

        let artistText = authorText.isEmpty ? info.artist : authorText

        return (artistText, titleText)
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
