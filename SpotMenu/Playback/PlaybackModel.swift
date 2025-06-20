import Foundation
import SwiftUI

extension Notification.Name {
    static let contentModelDidUpdate = Notification.Name(
        "PlaybackModelDidUpdate"
    )
}

class PlaybackModel: ObservableObject {
    @Published var imageURL: URL?
    @Published var isPlaying: Bool = false
    @Published var songTitle: String = ""
    @Published var songArtist: String = ""
    @Published var totalTime: Double = 1  // Default to avoid 0...0 range
    @Published var currentTime: Double = 0

    private var timer: Timer?

    init() {
        fetchSpotifyInfo()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            self.fetchSpotifyInfo()
        }
    }

    func fetchSpotifyInfo() {
        let script = """
            tell application "Spotify"
                if it is running then
                    set trackName to name of current track
                    set artistName to artist of current track
                    set artworkUrl to artwork url of current track
                    set durationSec to duration of current track
                    set currentSec to player position
                    set isPlayingState to (player state is playing)
                    return trackName & "|||SEP|||" & artistName & "|||SEP|||" & artworkUrl & "|||SEP|||" & durationSec & "|||SEP|||" & currentSec & "|||SEP|||" & isPlayingState
                else
                    return "NOT_RUNNING"
                end if
            end tell
            """

        if let output = runAppleScript(script), output != "NOT_RUNNING" {
            let parts = output.components(separatedBy: "|||SEP|||")
            if parts.count == 6 {
                DispatchQueue.main.async {
                    self.songTitle = parts[0]
                    self.songArtist = parts[1]
                    self.imageURL = URL(string: parts[2])
                    let durationMs = Double(parts[3]) ?? 1000
                    self.totalTime = durationMs / 1000.0
                    let currentTimeStr = parts[4].replacingOccurrences(
                        of: ",",
                        with: "."
                    )
                    self.currentTime = min(
                        Double(currentTimeStr) ?? 0,
                        self.totalTime
                    )
                    self.isPlaying =
                        (parts[5].trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ) == "true")

                    NotificationCenter.default.post(
                        name: .contentModelDidUpdate,
                        object: nil
                    )
                }
            }
        } else {
            self.songTitle = ""
            self.songArtist = ""
            self.isPlaying = false
            self.imageURL = nil
            self.currentTime = 0
            self.totalTime = 1
        }
    }

    func skipForward() {
        _ = runAppleScript("tell application \"Spotify\" to next track")
        delayedFetch()
    }

    func skipBack() {
        _ = runAppleScript("tell application \"Spotify\" to previous track")
        delayedFetch()
    }

    func togglePlayPause() {
        if self.isPlaying {
            _ = runAppleScript("tell application \"Spotify\" to pause")
        } else {
            _ = runAppleScript("tell application \"Spotify\" to play")
        }
        self.isPlaying = !self.isPlaying

        delayedFetch()
    }

    private func delayedFetch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.fetchSpotifyInfo()
        }
    }

    func updatePlaybackPosition(to seconds: Double) {
        _ = runAppleScript(
            "tell application \"Spotify\" to set player position to \(Int(seconds))"
        )
        self.currentTime = seconds
    }

    func openSpotify() {
        guard
            let url = NSWorkspace.shared.urlForApplication(
                withBundleIdentifier: "com.spotify.client"
            )
        else {
            print("Spotify is not installed.")
            return
        }

        let config = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.openApplication(at: url, configuration: config) {
            app,
            error in
            if let error = error {
                print("Failed to open Spotify: \(error.localizedDescription)")
            }
        }
    }

    private func runAppleScript(_ script: String) -> String? {
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            let output = scriptObject.executeAndReturnError(&error)
            return output.stringValue
        }
        return nil
    }
}
