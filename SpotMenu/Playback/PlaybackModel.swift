import SwiftUI

extension Notification.Name {
    static let contentModelDidUpdate = Notification.Name(
        "PlaybackModelDidUpdate"
    )
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
    @Published var songTitle: String = ""
    @Published var songArtist: String = ""
    @Published var totalTime: Double = 1
    @Published var currentTime: Double = 0

    private let controller: MusicPlayerController
    private var timer: Timer?

    init(controller: MusicPlayerController) {
        self.controller = controller
        fetchInfo()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            self.fetchInfo()
        }
    }

    func fetchInfo() {
        guard let info = controller.fetchNowPlayingInfo() else {
            reset()
            return
        }

        DispatchQueue.main.async {
            self.songTitle = info.title
            self.songArtist = info.artist
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
            self.songTitle = ""
            self.songArtist = ""
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
