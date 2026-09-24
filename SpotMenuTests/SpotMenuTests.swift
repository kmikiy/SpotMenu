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
        let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: nil,
                                       headerFields: ["Content-Type": "application/json"])!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

@Suite(.serialized)
struct SpotMenuTests {
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
                    "durationInMillis": 200_000,
                    "artwork": ["url": "https://example.com/{w}x{h}.jpg"]
                ]
            ],
            "time": ["currentTime": 12.5, "duration": 200.0]
        ])
        #expect(snapshot.trackID == "song-1")
        #expect(snapshot.info?.isPlaying == true)
        #expect(snapshot.info?.title == "Track")
        #expect(snapshot.info?.currentTime == 12.5)
        #expect(snapshot.info?.totalTime == 200)
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
        #expect(clock.acceptSnapshot(trackID: "old", elapsed: 77, duration: 240,
                                     playing: true, at: start) == 77)
        clock.markTrackChange(at: start.addingTimeInterval(1))
        clock.markTrackChange(at: start.addingTimeInterval(1.05))
        #expect(clock.current(at: start.addingTimeInterval(1)) == 0)
        #expect(clock.shouldWaitForNewTrack("old", at: start.addingTimeInterval(1.1)))
        #expect(clock.acceptSnapshot(trackID: "new", elapsed: 77, duration: 260,
                                     playing: true, at: start.addingTimeInterval(1.2)) == 0)
        #expect(!clock.shouldWaitForNewTrack("new", at: start.addingTimeInterval(1.3)))
        #expect(clock.acceptTime(0.5, at: start.addingTimeInterval(1.5)) == 0.5)
        #expect(abs(clock.acceptTime(78, at: start.addingTimeInterval(1.6)) - 0.6) < 0.001)
        #expect(clock.current(at: start.addingTimeInterval(3.5)) == 2.5)
    }

    @Test func ciderProgressStartsAtActualPositionAndStopsWhenPaused() {
        var clock = CiderProgressClock()
        let start = Date(timeIntervalSince1970: 2_000)
        #expect(clock.acceptSnapshot(trackID: "song", elapsed: 31, duration: 100,
                                     playing: true, at: start) == 31)
        #expect(clock.current(at: start.addingTimeInterval(2)) == 33)
        #expect(clock.acceptTime(33, playing: false, at: start.addingTimeInterval(2)) == 33)
        #expect(clock.current(at: start.addingTimeInterval(5)) == 33)
    }

    @Test func ciderAutomixAcceptsNewSongOffsetAndLaterCorrectsDrift() {
        var clock = CiderProgressClock()
        let start = Date(timeIntervalSince1970: 3_000)
        _ = clock.acceptSnapshot(trackID: "old", elapsed: 260, duration: 300,
                                 playing: true, at: start)
        clock.markTrackChange(at: start.addingTimeInterval(1))
        #expect(clock.acceptSnapshot(trackID: "new", elapsed: 21, duration: 240,
                                     playing: true, at: start.addingTimeInterval(1.2)) == 21)
        #expect(clock.current(at: start.addingTimeInterval(3.2)) == 23)
        #expect(clock.acceptSnapshot(trackID: "new", elapsed: 30, duration: 240,
                                     playing: true, at: start.addingTimeInterval(31)) == 30)
    }

    @Test func ciderLiveUpdatesFallBackAfterPlayingEventSilence() {
        let start = Date(timeIntervalSince1970: 4_000)
        #expect(!CiderLiveUpdates.shouldMarkUnavailable(
            isPlaying: true, lastEventAt: nil, checkingSince: start,
            at: start.addingTimeInterval(5.9)))
        #expect(CiderLiveUpdates.shouldMarkUnavailable(
            isPlaying: true, lastEventAt: nil, checkingSince: start,
            at: start.addingTimeInterval(6)))
        #expect(!CiderLiveUpdates.shouldMarkUnavailable(
            isPlaying: false, lastEventAt: nil, checkingSince: start,
            at: start.addingTimeInterval(30)))
        #expect(!CiderLiveUpdates.shouldMarkUnavailable(
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
        let response = HTTPURLResponse(url: task.originalRequest!.url!, statusCode: 302,
                                       httpVersion: nil, headerFields: ["Location": "https://example.com/"])!
        var redirectedRequest = URLRequest(url: URL(string: "https://example.com/")!)
        redirectedRequest.setValue("test-value", forHTTPHeaderField: "apptoken")
        var allowed: URLRequest?
        delegate.urlSession(.shared, task: task, willPerformHTTPRedirection: response,
                            newRequest: redirectedRequest) { allowed = $0 }
        #expect(allowed == nil)
    }

    @Test @MainActor func ciderAuthorizationRequestsPlaybackScopeWithoutToken() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [CiderRequestStub.self]
        let session = URLSession(configuration: configuration)
        let rpc = CiderRPC(endpoint: CiderEndpoint(host: "127.0.0.1", port: 10767),
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
            #expect(body?["scopes"] as? [String] == ["playback"])
            return (200, Data("{\"data\":{\"token\":\"test-value\",\"scopes\":[\"playback\"]}}".utf8))
        }
        defer { CiderRequestStub.handle = nil }
        #expect(try await rpc.authorize() == "test-value")
    }

    @Test @MainActor func ciderPreviousUsesDefaultBehavior() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [CiderRequestStub.self]
        let rpc = CiderRPC(endpoint: CiderEndpoint(host: "127.0.0.1", port: 10767),
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
}
