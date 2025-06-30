import SwiftUI

class SpotifyController: MusicPlayerController {
    private var lastTrackID: String?
    private var lastIsLiked: Bool?

    func fetchNowPlayingInfo() -> PlaybackInfo? {
        let script = """
                tell application "Spotify"
                    if it is running then
                        set trackName to name of current track
                        set artistName to artist of current track
                        set artworkUrl to artwork url of current track
                        set durationSec to duration of current track
                        set currentSec to player position
                        set isPlayingState to (player state is playing)
                        set trackId to id of current track
                        return trackName & "|||SEP|||" & artistName & "|||SEP|||" & artworkUrl & "|||SEP|||" & durationSec & "|||SEP|||" & currentSec & "|||SEP|||" & isPlayingState & "|||SEP|||" & trackId
                    else
                        return "NOT_RUNNING"
                    end if
                end tell
            """

        guard let output = runAppleScript(script), output != "NOT_RUNNING"
        else {
            return nil
        }

        let parts = output.components(separatedBy: "|||SEP|||")
        guard parts.count == 7 else { return nil }

        let title = parts[0]
        let artist = parts[1]
        let imageURL = URL(string: parts[2])
        let totalTime = (Double(parts[3]) ?? 1000) / 1000.0
        let currentTime =
            Double(parts[4].replacingOccurrences(of: ",", with: ".")) ?? 0
        let isPlaying =
            parts[5].trimmingCharacters(in: .whitespacesAndNewlines) == "true"
        let trackURI = parts[6].trimmingCharacters(in: .whitespacesAndNewlines)
        let trackID = trackURI.components(separatedBy: ":").last

        var isLikedResult: Bool? = lastIsLiked

        // Fetch isLiked only if track has changed
        if let trackID = trackID, trackID != lastTrackID {
            let semaphore = DispatchSemaphore(value: 0)

            SpotifyAuthManager.shared.checkIfTrackIsLiked(trackID: trackID) {
                isLiked in
                self.lastIsLiked = isLiked
                isLikedResult = isLiked
                semaphore.signal()
            }

            _ = semaphore.wait(timeout: .now() + 2)
            lastTrackID = trackID
        }

        return PlaybackInfo(
            artist: artist,
            title: title,
            isPlaying: isPlaying,
            imageURL: imageURL,
            totalTime: totalTime,
            currentTime: min(currentTime, totalTime),
            image: nil,
            isLiked: isLikedResult
        )
    }

    func togglePlayPause() {
        let state = fetchNowPlayingInfo()?.isPlaying == true ? "pause" : "play"
        _ = runAppleScript("tell application \"Spotify\" to \(state)")
    }

    func skipForward() {
        _ = runAppleScript("tell application \"Spotify\" to next track")
    }

    func skipBack() {
        _ = runAppleScript("tell application \"Spotify\" to previous track")
    }

    func updatePlaybackPosition(to seconds: Double) {
        _ = runAppleScript(
            "tell application \"Spotify\" to set player position to \(Int(seconds))"
        )
    }

    func openApp() {
        SpotMenu.openApp(bundleIdentifier: "com.spotify.client")
    }

    func toggleLiked() {
        guard let trackID = getCurrentTrackID() else { return }

        SpotifyAuthManager.shared.checkIfTrackIsLiked(trackID: trackID) {
            isLiked in
            guard let isLiked = isLiked else {
                DispatchQueue.main.async {
                    LoginWindowManager.showLoginWindow()
                }
                return
            }

            if isLiked {
                SpotifyAuthManager.shared.removeTrackFromLiked(trackID: trackID)
                self.lastIsLiked = false
            } else {
                SpotifyAuthManager.shared.addTrackToLiked(trackID: trackID)
                self.lastIsLiked = true
            }
        }
    }

    func likeTrack() {
        guard let trackID = getCurrentTrackID() else { return }

        SpotifyAuthManager.shared.checkIfTrackIsLiked(trackID: trackID) {
            isLiked in
            guard let isLiked = isLiked else {
                DispatchQueue.main.async {
                    LoginWindowManager.showLoginWindow()
                }
                return
            }

            if !isLiked {
                SpotifyAuthManager.shared.addTrackToLiked(trackID: trackID)
            }
            self.lastIsLiked = true
        }
    }

    func unlikeTrack() {
        guard let trackID = getCurrentTrackID() else { return }

        SpotifyAuthManager.shared.checkIfTrackIsLiked(trackID: trackID) {
            isLiked in
            guard let isLiked = isLiked else {
                DispatchQueue.main.async {
                    LoginWindowManager.showLoginWindow()
                }
                return
            }

            if isLiked {
                SpotifyAuthManager.shared.removeTrackFromLiked(trackID: trackID)
            }
            self.lastIsLiked = false
        }
    }

    private func getCurrentTrackID() -> String? {
        let script = """
                tell application "Spotify"
                    if it is running then
                        return id of current track
                    else
                        return "NOT_RUNNING"
                    end if
                end tell
            """
        guard let trackURI = runAppleScript(script),
            trackURI != "NOT_RUNNING",
            let trackID = trackURI.components(separatedBy: ":").last
        else {
            return nil
        }
        return trackID
    }
}
