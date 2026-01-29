import Foundation
import SwiftUI

class SpotifyController: MusicPlayerController {
    private var lastTrackID: String?
    private var lastTrackType: String?
    private var lastIsLiked: Bool?
    private var longFormInfoCache =
        LRUCache<String, LongFormInfo>(capacity: 100)

    private let preferences: MusicPlayerPreferencesModel

    init(preferences: MusicPlayerPreferencesModel) {
        self.preferences = preferences
    }

    func fetchNowPlayingInfo() -> PlaybackInfo? {
        let script = """
                tell application "Spotify"
                    if it is running then
                        set trackName to name of current track
                        set artistName to artist of current track
                        set albumName to album of current track
                        set artworkUrl to artwork url of current track
                        set durationSec to duration of current track
                        set currentSec to player position
                        set isPlayingState to (player state is playing)
                        set trackId to id of current track
                        return trackName & "|||SEP|||" & artistName & "|||SEP|||" & artworkUrl & "|||SEP|||" & durationSec & "|||SEP|||" & currentSec & "|||SEP|||" & isPlayingState & "|||SEP|||" & trackId & "|||SEP|||" & albumName
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
        guard parts.count == 8 else { return nil }

        let title = parts[0]
        let artist = parts[1]
        let imageURL = URL(string: parts[2])
        let totalTime = (Double(parts[3]) ?? 1000) / 1000.0
        let currentTime =
            Double(parts[4].replacingOccurrences(of: ",", with: ".")) ?? 0
        let isPlaying =
            parts[5].trimmingCharacters(in: .whitespacesAndNewlines) == "true"
        let trackURI = parts[6].trimmingCharacters(in: .whitespacesAndNewlines)
        let album = parts[7]
        let trackComponents = trackURI.components(separatedBy: ":")
        let trackID = trackComponents.last
        let trackType = trackComponents.count > 1 ? trackComponents[1] : nil
        let longFormKind: LongFormKind?
        switch trackType {
        case "chapter": longFormKind = .audiobook
        case "episode": longFormKind = .podcastEpisode
        default: longFormKind = nil
        }
        let isTrack = trackType == "track"
        let isLongForm = longFormKind != nil
        lastTrackType = trackType

        var isLikedResult: Bool? = lastIsLiked
        var longFormInfo: LongFormInfo? = nil

        if !isTrack {
            isLikedResult = nil
            lastIsLiked = nil
        }

        if isLongForm, let trackID, let longFormKind {
            let cacheKey = "\(trackType ?? "unknown")|\(trackID)"
            if let cached = longFormInfoCache[cacheKey] {
                longFormInfo = cached
            } else if let fetched = fetchLongFormInfo(
                id: trackID,
                kind: longFormKind,
                chapterTitle: title,
                fallbackAlbum: album,
                fallbackArtist: artist
            ) {
                longFormInfo = fetched
                longFormInfoCache[cacheKey] = fetched
            }
        }

        if let trackID = trackID, trackID != lastTrackID, isTrack {
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
            isLiked: isLikedResult,
            longFormInfo: longFormInfo
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
        guard let trackID = getCurrentTrackID(), lastTrackType == "track"
        else { return }

        SpotifyAuthManager.shared.checkIfTrackIsLiked(trackID: trackID) {
            isLiked in
            guard let isLiked = isLiked else {
                DispatchQueue.main.async {
                    LoginWindowManager.showLoginWindow(with: self.preferences)
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
        guard let trackID = getCurrentTrackID(), lastTrackType == "track"
        else { return }

        SpotifyAuthManager.shared.checkIfTrackIsLiked(trackID: trackID) {
            isLiked in
            guard let isLiked = isLiked else {
                DispatchQueue.main.async {
                    LoginWindowManager.showLoginWindow(with: self.preferences)
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
        guard let trackID = getCurrentTrackID(), lastTrackType == "track"
        else { return }

        SpotifyAuthManager.shared.checkIfTrackIsLiked(trackID: trackID) {
            isLiked in
            guard let isLiked = isLiked else {
                DispatchQueue.main.async {
                    LoginWindowManager.showLoginWindow(with: self.preferences)
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
            trackURI != "NOT_RUNNING"
        else {
            return nil
        }
        let components = trackURI.components(separatedBy: ":")
        lastTrackType = components.count > 1 ? components[1] : nil
        guard let trackID = components.last else { return nil }
        return trackID
    }

    private func fetchLongFormInfo(
        id: String,
        kind: LongFormKind,
        chapterTitle: String,
        fallbackAlbum: String,
        fallbackArtist: String
    ) -> LongFormInfo? {
        var fetchedInfo: LongFormInfo?
        let semaphore = DispatchSemaphore(value: 0)

        SpotifyAuthManager.shared.getAccessToken { token in
            guard let token = token,
                let url = self.makeLongFormURL(id: id, kind: kind)
            else {
                semaphore.signal()
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )

            URLSession.shared.dataTask(with: request) { data, _, error in
                defer { semaphore.signal() }

                guard let data = data, error == nil else { return }

                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    if kind == .audiobook {
                        let chapter = try decoder.decode(
                            SpotifyChapter.self,
                            from: data
                        )

                        if let audiobook = chapter.audiobook {
                            let authors =
                                audiobook.authors?.map { $0.name }.filter {
                                    !$0.isEmpty
                                } ?? []
                            fetchedInfo = LongFormInfo(
                                kind: .audiobook,
                                title: audiobook.name,
                                authors: authors,
                                segmentTitle: chapter.name.isEmpty
                                    ? chapterTitle : chapter.name
                            )
                        }
                    } else if kind == .podcastEpisode {
                        let episode = try decoder.decode(
                            SpotifyEpisode.self,
                            from: data
                        )
                        if let show = episode.show {
                            let authors = [show.publisher].compactMap { $0 }
                            fetchedInfo = LongFormInfo(
                                kind: .podcastEpisode,
                                title: show.name,
                                authors: authors,
                                segmentTitle: episode.name.isEmpty
                                    ? chapterTitle : episode.name
                            )
                        }
                    }
                } catch {
                    // Ignore decoding failures and fall back below
                }
            }.resume()
        }

        _ = semaphore.wait(timeout: .now() + 2)
        if fetchedInfo == nil {
            // Fallback to basic metadata if API failed
            let authors =
                fallbackArtist.split(separator: ",").map {
                    $0.trimmingCharacters(in: .whitespaces)
                }.filter { !$0.isEmpty }
            fetchedInfo = LongFormInfo(
                kind: kind,
                title: fallbackAlbum.isEmpty ? chapterTitle : fallbackAlbum,
                authors: authors,
                segmentTitle: chapterTitle
            )
        }
        return fetchedInfo
    }

    private func makeLongFormURL(id: String, kind: LongFormKind) -> URL? {
        switch kind {
        case .audiobook:
            return URL(
                string:
                    "https://api.spotify.com/v1/chapters/\(id)?market=from_token"
            )
        case .podcastEpisode:
            return URL(
                string:
                    "https://api.spotify.com/v1/episodes/\(id)?market=from_token"
            )
        }
    }

}

private final class LRUCache<Key: Hashable, Value> {
    private let capacity: Int
    private var values: [Key: Value] = [:]
    private var order: [Key] = []

    init(capacity: Int) {
        self.capacity = max(1, capacity)
    }

    subscript(key: Key) -> Value? {
        get { value(for: key) }
        set {
            if let value = newValue {
                setValue(value, for: key)
            } else {
                removeValue(for: key)
            }
        }
    }

    private func value(for key: Key) -> Value? {
        guard let value = values[key] else { return nil }
        touch(key)
        return value
    }

    private func setValue(_ value: Value, for key: Key) {
        values[key] = value
        touch(key)
        trimToCapacity()
    }

    private func removeValue(for key: Key) {
        values.removeValue(forKey: key)
        if let index = order.firstIndex(of: key) {
            order.remove(at: index)
        }
    }

    private func touch(_ key: Key) {
        if let index = order.firstIndex(of: key) {
            order.remove(at: index)
        }
        order.append(key)
    }

    private func trimToCapacity() {
        while values.count > capacity, !order.isEmpty {
            let lruKey = order.removeFirst()
            values.removeValue(forKey: lruKey)
        }
    }
}

private struct SpotifyChapter: Decodable {
    let name: String
    let audiobook: SpotifySimplifiedAudiobook?
}

private struct SpotifyEpisode: Decodable {
    let name: String
    let show: SpotifyShow?
}

private struct SpotifyShow: Decodable {
    let name: String
    let publisher: String?
}

private struct SpotifySimplifiedAudiobook: Decodable {
    let name: String
    let authors: [SpotifyAuthor]?
}

private struct SpotifyAuthor: Decodable {
    let name: String
}
