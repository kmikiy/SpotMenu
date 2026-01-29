import AppKit
import Foundation
import SwiftUI

class AppleMusicController: MusicPlayerController {
    private var lastArtist: String?
    private var lastTitle: String?
    private var lastImage: NSImage?

    func fetchNowPlayingInfo() -> PlaybackInfo? {
        let script = """
                tell application \"Music\"
                    if it is running then
                        set trackName to name of current track
                        set artistName to artist of current track
                        set durationSec to duration of current track
                        set currentSec to player position
                        set isPlayingState to (player state is playing)
                        return trackName & \"|||SEP|||\" & artistName & \"|||SEP|||\" & durationSec & \"|||SEP|||\" & currentSec & \"|||SEP|||\" & isPlayingState
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
        if parts.count == 5 {
            let artist = parts[1]
            let title = parts[0]
            let totalTime =
                Double(parts[2].replacingOccurrences(of: ",", with: ".")) ?? 1
            let currentTime =
                Double(parts[3].replacingOccurrences(of: ",", with: ".")) ?? 0
            let isPlaying =
                parts[4].trimmingCharacters(in: .whitespacesAndNewlines)
                == "true"

            if artist != lastArtist || title != lastTitle {
                lastImage = getCurrentTrackArtwork()
                lastArtist = artist
                lastTitle = title
            }

            return PlaybackInfo(
                artist: artist,
                title: title,
                isPlaying: isPlaying,
                imageURL: nil,
                totalTime: totalTime,
                currentTime: currentTime,
                image: lastImage != nil ? Image(nsImage: lastImage!) : nil,
                isLiked: nil,
                longFormInfo: nil
            )
        }

        return nil
    }

    func getCurrentTrackArtwork() -> NSImage? {
        let script = """
            tell application \"Music\"
                    if it is running then
                        get data of artwork 1 of current track
                    end if
            end tell
            """

        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            let output = scriptObject.executeAndReturnError(&error)
            let data = output.data
            return NSImage(data: data)
        }

        if let error = error {
            print("AppleScript Error: \(error)")
        }

        return nil
    }

    func togglePlayPause() {
        let state = fetchNowPlayingInfo()?.isPlaying == true ? "pause" : "play"
        _ = runAppleScript("tell application \"Music\" to \(state)")
    }

    func skipForward() {
        _ = runAppleScript("tell application \"Music\" to next track")
    }

    func skipBack() {
        _ = runAppleScript("tell application \"Music\" to previous track")
    }

    func updatePlaybackPosition(to seconds: Double) {
        _ = runAppleScript(
            "tell application \"Music\" to set player position to \(Int(seconds))"
        )
    }

    func openApp() {
        SpotMenu.openApp(bundleIdentifier: "com.apple.Music")
    }

    func toggleLiked() {
        print("Apple Music does not support liking tracks (yet).")
    }

    func likeTrack() {
        print("Apple Music does not support liking tracks (yet).")
    }

    func unlikeTrack() {
        print("Apple Music does not support unliking tracks (yet).")
    }
}
