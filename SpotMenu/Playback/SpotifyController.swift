import SwiftUI

class SpotifyController: MusicPlayerController {
    func fetchNowPlayingInfo() -> PlaybackInfo? {
        let script = """
                tell application \"Spotify\"
                    if it is running then
                        set trackName to name of current track
                        set artistName to artist of current track
                        set artworkUrl to artwork url of current track
                        set durationSec to duration of current track
                        set currentSec to player position
                        set isPlayingState to (player state is playing)
                        return trackName & \"|||SEP|||\" & artistName & \"|||SEP|||\" & artworkUrl & \"|||SEP|||\" & durationSec & \"|||SEP|||\" & currentSec & \"|||SEP|||\" & isPlayingState
                    else
                        return \"NOT_RUNNING\"
                    end if
                end tell
            """

        guard let output = runAppleScript(script), output != "NOT_RUNNING"
        else {
            return nil
        }

        let parts = output.components(separatedBy: "|||SEP|||")
        if parts.count == 6 {
            let artist = parts[1]
            let title = parts[0]
            let imageURL = URL(string: parts[2])
            let totalTime = (Double(parts[3]) ?? 1000) / 1000.0
            let currentTime =
                Double(parts[4].replacingOccurrences(of: ",", with: ".")) ?? 0
            let isPlaying =
                parts[5].trimmingCharacters(in: .whitespacesAndNewlines)
                == "true"

            return PlaybackInfo(
                artist: artist,
                title: title,
                isPlaying: isPlaying,
                imageURL: imageURL,
                totalTime: totalTime,
                currentTime: min(currentTime, totalTime)
            )
        }

        return nil
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
}
