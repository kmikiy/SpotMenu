import Foundation
import Testing
@testable import SpotMenu

private final class CiderRequestStub: URLProtocol {
    static var handle: ((URLRequest) -> (Int, Data))?

    override static func canInit(with request: URLRequest) -> Bool { true }
    override static func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handle = Self.handle, let url = request.url else { return }
        let (status, data) = handle(request)
        let response = HTTPURLResponse(
            url: url, statusCode: status, httpVersion: nil,
            headerFields: ["Content-Type": "application/json"])!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

private func requestBody(_ request: URLRequest) -> Data {
    if let body = request.httpBody { return body }
    guard let stream = request.httpBodyStream else { return Data() }
    stream.open()
    defer { stream.close() }
    var bytes = [UInt8](repeating: 0, count: 4096)
    let count = stream.read(&bytes, maxLength: bytes.count)
    return Data(bytes.prefix(max(0, count)))
}

@Suite(.serialized)
struct SpotMenuTests {
    @Test @MainActor func spotifastLikedIconDoesNotRequireSpotifyLiking() {
        let defaults = UserDefaults.standard
        let keys = ["musicPlayer.preferredMusicApp", "musicPlayer.likingEnabled", "menuBar.showIsLikedIcon"]
        let savedValues = keys.map { defaults.object(forKey: $0) }
        defer {
            for (key, value) in zip(keys, savedValues) { defaults.set(value, forKey: key) }
        }
        let music = MusicPlayerPreferencesModel()
        music.preferredMusicApp = .spotifast
        music.likingEnabled = false
        let playback = PlaybackModel(preferences: music)
        defer { playback.spotifast.stop() }
        let menu = MenuBarPreferencesModel()
        menu.showIsLikedIcon = true
        let status = StatusItemModel()
        status.isLiked = true
        #expect(
            status.computeDisplayOptions(
                menuBarPreferencesModel: menu,
                musicPlayerPreferencesModel: music, playbackModel: playback
            ).showHeartIcon)
        menu.showIsLikedIcon = false
        #expect(
            !status.computeDisplayOptions(
                menuBarPreferencesModel: menu,
                musicPlayerPreferencesModel: music, playbackModel: playback
            ).showHeartIcon)
    }

    @Test(.enabled(if: ProcessInfo.processInfo.environment["SPOTMENU_LIVE_SPOTIFAST"] == "1"))
    func spotifastBridgeReadsLivePlayer() async throws {
        let output = try await SpotifastBridge.run(["now-playing", "--raw"])
        let info = try #require(SpotifastSnapshot.parse(output))
        #expect(!info.title.isEmpty)
        #expect(info.totalTime > 0)
        #expect(info.imageURL != nil)
        // Exercise a command without changing the listener's playback state.
        _ = try await SpotifastBridge.run([info.isPlaying ? "play" : "pause"])
        let refreshed = SpotifastSnapshot.parse(try await SpotifastBridge.run(["now-playing", "--raw"]))
        #expect(refreshed?.title == info.title)
        #expect(refreshed?.isPlaying == info.isPlaying)
    }

    @Test func spotifastSnapshotReadsMetadataAndMilliseconds() {
        let snapshot = SpotifastSnapshot.parse(
            "playing\tSong\tArtist One, Artist Two\tAlbum\t8278\t267880\t100\toff\toff\thttps://example.com/art.jpg\tyes\tThis computer\n"
        )
        #expect(snapshot?.title == "Song")
        #expect(snapshot?.artist == "Artist One, Artist Two")
        #expect(snapshot?.isPlaying == true)
        #expect(snapshot?.currentTime == 8.278)
        #expect(snapshot?.totalTime == 267.88)
        #expect(snapshot?.isLiked == true)
        #expect(snapshot?.imageURL?.absoluteString == "https://example.com/art.jpg")
    }

    @Test func spotifastSnapshotHandlesStoppedUnknownAndFutureFields() {
        #expect(SpotifastSnapshot.parse("stopped\n") == nil)
        #expect(SpotifastSnapshot.parse("playing\tIncomplete") == nil)
        let snapshot = SpotifastSnapshot.parse(
            "paused\tSong\tArtist\tAlbum\t10000\t5000\t100\toff\toff\t\tunknown\tDevice\tfuture-field\n"
        )
        #expect(snapshot?.isPlaying == false)
        #expect(snapshot?.currentTime == 5)
        #expect(snapshot?.imageURL == nil)
        #expect(snapshot?.isLiked == nil)
        #expect(
            SpotifastSnapshot.parse(
                "playing\tSong\tArtist\tAlbum\tNaN\t5000\t100\toff\toff\t\tno\tDevice"
            ) == nil)
    }

    @Test func spotifastBridgeAcceptsOnlyPlaybackCommands() {
        #expect(SpotifastBridgeCommand.isAllowed(["now-playing", "--raw"]))
        #expect(SpotifastBridgeCommand.isAllowed(["seek-to", "90"]))
        #expect(SpotifastBridgeCommand.isAllowed(["play-pause"]))
        #expect(!SpotifastBridgeCommand.isAllowed(["seek-to", "-1"]))
        #expect(!SpotifastBridgeCommand.isAllowed(["seek-to", "nan"]))
        #expect(!SpotifastBridgeCommand.isAllowed(["--verbose"]))
        #expect(!SpotifastBridgeCommand.isAllowed(["play", "unexpected"]))
        #expect(!SpotifastBridgeCommand.isAllowed(["sh", "-c", "echo unsafe"]))
    }

    @Test func ciderEndpointAcceptsOnlyLoopback() {
        #expect(CiderEndpoint(host: "127.0.0.1", port: 10767).url?.absoluteString == "http://127.0.0.1:10767")
        #expect(CiderEndpoint(host: "localhost", port: 10767).url?.host == "127.0.0.1")
        #expect(CiderEndpoint(host: "::1", port: 10767).url != nil)
        #expect(CiderEndpoint(host: "example.com", port: 10767).url == nil)
        #expect(CiderEndpoint(host: "127.0.0.1.evil.com", port: 10767).url == nil)
        #expect(CiderEndpoint(host: "127.0.0.1", port: 0).url == nil)
    }

    @Test func ciderSnapshotReadsArtworkAndTime() {
        let snapshot = CiderSnapshot.parse([
            "state": "playing",
            "nowPlaying": [
                "id": "song-1",
                "attributes": [
                    "name": "Track", "artistName": "Artist", "albumName": "Album",
                    "durationInMillis": 200_000, "inFavorites": true,
                    "artwork": ["url": "https://example.com/{w}x{h}.jpg"],
                ],
            ],
            "time": ["currentTime": 12.5, "duration": 200.0],
        ])
        #expect(snapshot.trackID == "song-1")
        #expect(snapshot.info?.isPlaying == true)
        #expect(snapshot.info?.title == "Track")
        #expect(snapshot.info?.currentTime == 12.5)
        #expect(snapshot.info?.totalTime == 200)
        #expect(snapshot.info?.isLiked == true)
        #expect(snapshot.info?.imageURL?.absoluteString == "https://example.com/300x300.jpg")
    }

    @Test func ciderStoppedSnapshotClearsTrack() {
        let snapshot = CiderSnapshot.parse(["state": "stopped", "nowPlaying": NSNull()])
        #expect(snapshot.trackID == nil)
        #expect(snapshot.info == nil)
    }

    @Test func ciderProgressResetsAndRejectsPreviousTrackTime() {
        var clock = CiderProgressClock()
        let start = Date(timeIntervalSince1970: 1_000)
        #expect(
            clock.acceptSnapshot(
                trackID: "old", elapsed: 77, duration: 240,
                playing: true, at: start) == 77)
        clock.markTrackChange(at: start.addingTimeInterval(1))
        clock.markTrackChange(at: start.addingTimeInterval(1.05))
        #expect(clock.current(at: start.addingTimeInterval(1)) == 0)
        #expect(clock.shouldWaitForNewTrack("old", at: start.addingTimeInterval(1.1)))
        #expect(
            clock.acceptSnapshot(
                trackID: "new", elapsed: 77, duration: 260,
                playing: true, at: start.addingTimeInterval(1.2)) == 0)
        #expect(!clock.shouldWaitForNewTrack("new", at: start.addingTimeInterval(1.3)))
        #expect(clock.acceptTime(0.5, at: start.addingTimeInterval(1.5)) == 0.5)
        #expect(abs(clock.acceptTime(78, at: start.addingTimeInterval(1.6)) - 0.6) < 0.001)
        #expect(clock.current(at: start.addingTimeInterval(3.5)) == 2.5)
    }

    @Test func ciderProgressStartsAtActualPositionAndStopsWhenPaused() {
        var clock = CiderProgressClock()
        let start = Date(timeIntervalSince1970: 2_000)
        #expect(
            clock.acceptSnapshot(
                trackID: "song", elapsed: 31, duration: 100,
                playing: true, at: start) == 31)
        #expect(clock.current(at: start.addingTimeInterval(2)) == 33)
        #expect(clock.acceptTime(33, playing: false, at: start.addingTimeInterval(2)) == 33)
        #expect(clock.current(at: start.addingTimeInterval(5)) == 33)
    }

    @Test func ciderAutomixAcceptsNewSongOffsetAndLaterCorrectsDrift() {
        var clock = CiderProgressClock()
        let start = Date(timeIntervalSince1970: 3_000)
        _ = clock.acceptSnapshot(
            trackID: "old", elapsed: 260, duration: 300,
            playing: true, at: start)
        clock.markTrackChange(at: start.addingTimeInterval(1))
        #expect(
            clock.acceptSnapshot(
                trackID: "new", elapsed: 21, duration: 240,
                playing: true, at: start.addingTimeInterval(1.2)) == 21)
        #expect(clock.current(at: start.addingTimeInterval(3.2)) == 23)
        #expect(
            clock.acceptSnapshot(
                trackID: "new", elapsed: 30, duration: 240,
                playing: true, at: start.addingTimeInterval(31)) == 30)
    }

    @Test func ciderLiveUpdatesFallBackAfterPlayingEventSilence() {
        let start = Date(timeIntervalSince1970: 4_000)
        #expect(
            !CiderLiveUpdates.shouldMarkUnavailable(
                isPlaying: true, lastEventAt: nil, checkingSince: start,
                at: start.addingTimeInterval(5.9)))
        #expect(
            CiderLiveUpdates.shouldMarkUnavailable(
                isPlaying: true, lastEventAt: nil, checkingSince: start,
                at: start.addingTimeInterval(6)))
        #expect(
            !CiderLiveUpdates.shouldMarkUnavailable(
                isPlaying: false, lastEventAt: nil, checkingSince: start,
                at: start.addingTimeInterval(30)))
        #expect(
            !CiderLiveUpdates.shouldMarkUnavailable(
                isPlaying: true, lastEventAt: start.addingTimeInterval(10), checkingSince: start,
                at: start.addingTimeInterval(15)))
    }

    @Test func ciderLiveUpdatesPollQuicklyOnlyWithoutEvents() {
        #expect(CiderLiveUpdates.checking.snapshotInterval(connected: true) == 2)
        #expect(CiderLiveUpdates.unavailable.snapshotInterval(connected: true) == 2)
        #expect(CiderLiveUpdates.active.snapshotInterval(connected: true) == 30)
        #expect(CiderLiveUpdates.active.snapshotInterval(connected: false) == 15)
    }

    @Test func ciderRedirectIsNeverFollowed() {
        let delegate = CiderNoRedirect()
        let task = URLSession.shared.dataTask(with: URL(string: "http://127.0.0.1:10767/api/v2/playback")!)
        let response = HTTPURLResponse(
            url: task.originalRequest!.url!, statusCode: 302,
            httpVersion: nil, headerFields: ["Location": "https://example.com/"])!
        var redirectedRequest = URLRequest(url: URL(string: "https://example.com/")!)
        redirectedRequest.setValue("test-value", forHTTPHeaderField: "apptoken")
        var allowed: URLRequest?
        delegate.urlSession(
            .shared, task: task, willPerformHTTPRedirection: response,
            newRequest: redirectedRequest
        ) { allowed = $0 }
        #expect(allowed == nil)
    }

    @Test @MainActor func ciderAuthorizationRequestsPlaybackScopeWithoutToken() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [CiderRequestStub.self]
        let session = URLSession(configuration: configuration)
        let rpc = CiderRPC(
            endpoint: CiderEndpoint(host: "127.0.0.1", port: 10767),
            token: "stored-value", session: session)
        CiderRequestStub.handle = { request in
            #expect(request.url?.path == "/api/v2/auth/request")
            #expect(request.httpMethod == "POST")
            #expect(request.value(forHTTPHeaderField: "apptoken") == nil)
            let bodyData: Data
            if let direct = request.httpBody {
                bodyData = direct
            } else if let stream = request.httpBodyStream {
                stream.open()
                defer { stream.close() }
                var bytes = [UInt8](repeating: 0, count: 4096)
                let count = stream.read(&bytes, maxLength: bytes.count)
                bodyData = Data(bytes.prefix(max(0, count)))
            } else {
                bodyData = Data()
            }
            let body = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any]
            #expect(body?["app_name"] as? String == "SpotMenu")
            #expect(body?["scopes"] as? [String] == ["playback", "library"])
            return (200, Data("{\"data\":{\"token\":\"test-value\",\"scopes\":[\"playback\",\"library\"]}}".utf8))
        }
        defer { CiderRequestStub.handle = nil }
        #expect(try await rpc.authorize() == "test-value")
    }

    @Test @MainActor func ciderPreviousUsesDefaultBehavior() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [CiderRequestStub.self]
        let rpc = CiderRPC(
            endpoint: CiderEndpoint(host: "127.0.0.1", port: 10767),
            session: URLSession(configuration: configuration))
        CiderRequestStub.handle = { request in
            #expect(request.url?.path == "/api/v2/playback/previous")
            #expect(request.httpMethod == "POST")
            let body: Data
            if let direct = request.httpBody {
                body = direct
            } else if let stream = request.httpBodyStream {
                stream.open()
                defer { stream.close() }
                var bytes = [UInt8](repeating: 0, count: 4096)
                let count = stream.read(&bytes, maxLength: bytes.count)
                body = Data(bytes.prefix(max(0, count)))
            } else {
                body = Data()
            }
            let json = try? JSONSerialization.jsonObject(with: body) as? [String: Bool]
            #expect(json?["force"] == false)
            return (200, Data("{}".utf8))
        }
        defer { CiderRequestStub.handle = nil }
        try await rpc.control(.previous)
    }

    @Test @MainActor func ciderAuthorizationRequiresLibraryScopeForFavorites() async {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [CiderRequestStub.self]
        let rpc = CiderRPC(
            endpoint: CiderEndpoint(host: "127.0.0.1", port: 10767),
            session: URLSession(configuration: configuration))
        CiderRequestStub.handle = { _ in
            (200, Data("{\"data\":{\"token\":\"test-value\",\"scopes\":[\"playback\"]}}".utf8))
        }
        defer { CiderRequestStub.handle = nil }
        do {
            _ = try await rpc.authorize()
            Issue.record("Authorization accepted a token without library scope")
        } catch CiderRPCError.denied {
            // A limited token must not replace the existing Keychain item.
        } catch {
            Issue.record("Unexpected authorization error")
        }
    }

    @Test @MainActor func ciderSeekAndFavoritesUseV2RPC() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [CiderRequestStub.self]
        let rpc = CiderRPC(
            endpoint: CiderEndpoint(host: "127.0.0.1", port: 10767),
            token: "test-value", session: URLSession(configuration: configuration))
        CiderRequestStub.handle = { request in
            #expect(request.value(forHTTPHeaderField: "apptoken") == "test-value")
            switch (request.httpMethod, request.url?.path) {
            case ("POST", "/api/v2/playback/seek"):
                let json = try? JSONSerialization.jsonObject(with: requestBody(request)) as? [String: Double]
                #expect(json?["position"] == 42.5)
                return (204, Data())
            case ("GET", "/api/v2/library/now-playing/status"):
                return (200, Data("{\"data\":{\"rating\":1,\"inLibrary\":false}}".utf8))
            case ("POST", "/api/v2/library/now-playing/love"),
                ("DELETE", "/api/v2/library/now-playing/rating"):
                return (204, Data())
            default:
                Issue.record("Unexpected Cider RPC request")
                return (404, Data())
            }
        }
        defer { CiderRequestStub.handle = nil }
        try await rpc.seek(to: 42.5)
        #expect(try await rpc.favoriteStatus())
        try await rpc.setFavorite(true)
        try await rpc.setFavorite(false)
    }
}
