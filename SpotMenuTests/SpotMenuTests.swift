import Foundation
import Testing
@testable import SpotMenu

private final class CiderRequestStub: URLProtocol {
    static var handle: ((URLRequest) -> (Int, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

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
}
