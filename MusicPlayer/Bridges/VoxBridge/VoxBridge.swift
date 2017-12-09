import AppKit
import ScriptingBridge


// MARK: VoxApplication
@objc public protocol VoxApplication: SBApplicationProtocol {
    @objc optional var name: String { get } // The name of the application.
    @objc optional var frontmost: Bool { get } // Is this the frontmost (active) application?
    @objc optional var version: String { get } // The version of the application.
    @objc optional func quit() // Quit an application.
    @objc optional func pause() // Pause playback.
    @objc optional func play() // Begin playback.
    @objc optional func playpause() // Toggle playback between playing and paused.
    @objc optional func next() // Skip to the next track in the playlist.
    @objc optional func previous() // Skip to the previous track in the playlist.
    @objc optional func shuffle() // Shuffle the tracks in the playlist.
    @objc optional func playUrl(_ x: String!) // Play specified URL.
    @objc optional func addUrl(_ x: String!) // Add specified URL to playlist
    @objc optional func rewindForward() // Rewind current track forward.
    @objc optional func rewindForwardFast() // Rewind current track forward fast.
    @objc optional func rewindBackward() // Rewind current track backward.
    @objc optional func rewindBackwardFast() // Rewind current track backward fast.
    @objc optional func increasVolume() // Increas volume.
    @objc optional func decreaseVolume() // Decrease volume.
    @objc optional func showHidePlaylist() // Show/Hide playlist.
    @objc optional var tiffArtworkData: Data { get } // Current track artwork data in TIFF format.
    @objc optional var artworkImage: NSImage { get } // Current track artwork as an image.
    @objc optional var playerState: Int { get } // Player state (playing = 1, paused = 0)
    @objc optional var track: String { get } // Current track title.
    @objc optional var trackUrl: String { get } // Current track URL.
    @objc optional var artist: String { get } // Current track artist.
    @objc optional var albumArtist: String { get } // Current track album artist.
    @objc optional var album: String { get } // Current track album.
    @objc optional var uniqueID: String { get } // Unique identifier for the current track.
    @objc optional var currentTime: Double { get } // The current playback position.
    @objc optional var totalTime: Double { get } // The total time of the currenty playing track.
    @objc optional var playerVolume: Double { get } // Player volume (0.0 to 1.0)
    @objc optional var repeatState: Int { get } // Player repeat state (none = 0, repeat one = 1, repeat all = 2)
    @objc optional func setCurrentTime(_ currentTime: Double) // The current playback position.
    @objc optional func setPlayerVolume(_ playerVolume: Double) // Player volume (0.0 to 1.0)
    @objc optional func setRepeatState(_ repeatState: Int) // Player repeat state (none = 0, repeat one = 1, repeat all = 2)
}
extension SBApplication: VoxApplication {}

