import AppKit
import Foundation
import Security
import SocketIO

struct CiderEndpoint: Equatable {
    var host: String
    var port: Int

    var url: URL? {
        guard (1...65535).contains(port) else { return nil }
        let address: String
        switch host.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "127.0.0.1", "localhost": address = "127.0.0.1"
        case "::1", "[::1]": address = "[::1]"
        default: return nil
        }
        return URL(string: "http://\(address):\(port)")
    }
}

enum CiderConnection: Equatable {
    case offline, authorizationRequired, connected, failed(String)

    var message: String {
        switch self {
        case .offline: return "Cider is offline. Open Cider and enable RPC."
        case .authorizationRequired: return "Authorize SpotMenu in Cider."
        case .connected: return "Connected to Cider"
        case .failed(let message): return message
        }
    }
}

enum CiderRPCError: Error {
    case invalidEndpoint, offline, unauthorized, denied, timedOut, invalidResponse, http(Int)

    var message: String {
        switch self {
        case .invalidEndpoint: return "Use 127.0.0.1 or ::1 and a port from 1 to 65535."
        case .offline: return "Cider is offline. Open Cider and enable RPC."
        case .unauthorized: return "Cider authorization is missing or expired. Request it again."
        case .denied: return "Cider authorization was denied. Select Authorize to retry."
        case .timedOut: return "Cider did not answer the authorization request. Select Authorize to retry."
        case .invalidResponse: return "Cider returned an unexpected response."
        case .http(let status): return "Cider returned HTTP \(status)."
        }
    }
}

final class CiderNoRedirect: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(nil)
    }
}

@MainActor
final class CiderRPC {
    var endpoint: CiderEndpoint
    var token: String?
    private let session: URLSession

    init(endpoint: CiderEndpoint, token: String? = nil, session: URLSession? = nil) {
        self.endpoint = endpoint
        self.token = token
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 8
        self.session = session ?? URLSession(configuration: configuration, delegate: CiderNoRedirect(), delegateQueue: nil)
    }

    func clientInfo() async throws -> [String: Any] { try await request("client/info") }
    func playback() async throws -> CiderSnapshot { CiderSnapshot.parse(try await request("playback")) }

    func control(_ action: CiderAction) async throws {
        _ = try await request("playback/\(action.rawValue)", method: "POST",
                              body: action == .previous ? ["force": false] : nil)
    }

    func authorize() async throws -> String {
        let result = try await request("auth/request", method: "POST",
                                       body: ["app_name": "SpotMenu", "scopes": ["playback"]],
                                       authenticated: false, timeout: 90)
        guard let token = result["token"] as? String, !token.isEmpty else { throw CiderRPCError.invalidResponse }
        return token
    }

    private func request(_ path: String, method: String = "GET", body: [String: Any]? = nil,
                         authenticated: Bool = true, timeout: TimeInterval = 8) async throws -> [String: Any] {
        guard let base = endpoint.url else { throw CiderRPCError.invalidEndpoint }
        let url = base.appendingPathComponent("api/v2/\(path)")
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = timeout
        if authenticated, let token, !token.isEmpty {
            request.setValue(token, forHTTPHeaderField: "apptoken")
        }
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        let data: Data
        let response: URLResponse
        do { (data, response) = try await session.data(for: request) }
        catch let error as URLError {
            if error.code == .timedOut { throw CiderRPCError.timedOut }
            throw CiderRPCError.offline
        }
        guard let http = response as? HTTPURLResponse else { throw CiderRPCError.invalidResponse }
        if http.statusCode == 401 || http.statusCode == 403 {
            if !authenticated { throw CiderRPCError.denied }
            throw CiderRPCError.unauthorized
        }
        guard (200...299).contains(http.statusCode) else { throw CiderRPCError.http(http.statusCode) }
        if data.isEmpty { return [:] }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw CiderRPCError.invalidResponse
        }
        return json["data"] as? [String: Any] ?? json
    }
}

enum CiderAction: String { case previous, toggle, next }

struct CiderSnapshot {
    let trackID: String?
    let info: PlaybackInfo?

    static func parse(_ object: [String: Any]) -> CiderSnapshot {
        let state = object["state"] as? String ?? "stopped"
        guard let item = object["nowPlaying"] as? [String: Any] else {
            return CiderSnapshot(trackID: nil, info: nil)
        }
        let fields = item["attributes"] as? [String: Any] ?? item
        let title = fields["name"] as? String ?? ""
        let artist = fields["artistName"] as? String ?? ""
        guard !title.isEmpty || !artist.isEmpty else { return CiderSnapshot(trackID: nil, info: nil) }
        let album = fields["albumName"] as? String ?? ""
        let id = item["id"] as? String ?? fields["id"] as? String ?? "\(title)|\(artist)|\(album)"
        let artwork = fields["artwork"] as? [String: Any]
        let rawArtwork = artwork?["url"] as? String
        let artworkURL = rawArtwork.flatMap {
            URL(string: $0.replacingOccurrences(of: "{w}", with: "300")
                .replacingOccurrences(of: "{h}", with: "300"))
        }
        let time = object["time"] as? [String: Any]
        let duration = time?["duration"] as? Double ?? (fields["durationInMillis"] as? Double ?? 0) / 1000
        let elapsed = time?["currentTime"] as? Double ?? 0
        return CiderSnapshot(trackID: id, info: PlaybackInfo(
            artist: artist, title: title, isPlaying: state == "playing", imageURL: artworkURL,
            totalTime: max(1, duration), currentTime: max(0, elapsed), image: nil,
            isLiked: nil, longFormInfo: nil))
    }
}

enum CiderTokenStore {
    enum ReadResult { case token(String), missing, failed }
    private static let service = "com.jeremyhiggs.SpotMenu.cider.rpc"
    private static let account = "apptoken"

    private static var query: [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: service, kSecAttrAccount as String: account]
    }

    static func read() -> ReadResult {
        var request = query
        request[kSecReturnData as String] = true
        request[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(request as CFDictionary, &result)
        if status == errSecItemNotFound { return .missing }
        guard status == errSecSuccess, let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else { return .failed }
        return .token(token)
    }

    static func save(_ token: String) -> Bool {
        let data = Data(token.utf8)
        let status = SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        if status == errSecSuccess { return true }
        guard status == errSecItemNotFound else { return false }
        var item = query
        item[kSecValueData as String] = data
        return SecItemAdd(item as CFDictionary, nil) == errSecSuccess
    }
}

@MainActor
final class CiderSession: ObservableObject {
    @Published private(set) var connection: CiderConnection = .offline
    @Published private(set) var authorizationBusy = false
    @Published private(set) var rpcVersion: String?
    @Published private(set) var statusMessage: String?

    var onPlayback: ((PlaybackInfo?, Bool) -> Void)?
    private let preferences: MusicPlayerPreferencesModel
    private let rpc: CiderRPC
    private var socketManager: SocketManager?
    private var socket: SocketIOClient?
    private var monitor: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?
    private var refreshAgain = false
    private var socketConnected = false
    private var lastSocketEventAt: Date?
    private var socketRetryAfter = Date.distantPast
    private var lastSnapshotAt = Date.distantPast
    private var displayTimer: Timer?
    private var progress = CiderProgressClock()
    private var pendingPlaybackState: (playing: Bool, until: Date)?
    private var currentTrackID: String?
    private var currentInfo: PlaybackInfo?
    private var generation = 0
    private var tokenLoaded = false

    init(preferences: MusicPlayerPreferencesModel) {
        self.preferences = preferences
        rpc = CiderRPC(endpoint: CiderEndpoint(host: preferences.ciderHost, port: preferences.ciderPort))
    }

    func start() {
        guard monitor == nil else { return }
        if !tokenLoaded {
            switch CiderTokenStore.read() {
            case .token(let token): rpc.token = token
            case .missing: rpc.token = nil
            case .failed:
                connection = .failed("Keychain access failed. Check access and select Retry.")
                return
            }
            tokenLoaded = true
        }
        generation += 1
        displayTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tickProgress() }
        }
        refresh()
        monitor = Task { [weak self] in
            while let self, !Task.isCancelled {
                if self.socketConnected,
                   let lastEvent = self.lastSocketEventAt,
                   Date().timeIntervalSince(lastEvent) >= 15 {
                    self.suspendSilentSocket()
                }
                // Cider may start an Automix transition partway into a song.
                // A slow HTTP snapshot corrects any missed or incomplete socket time update.
                if !self.socketConnected || Date().timeIntervalSince(self.lastSnapshotAt) >= 30 {
                    self.refresh()
                }
                try? await Task.sleep(nanoseconds: 15_000_000_000)
            }
        }
    }

    func stop() {
        generation += 1
        monitor?.cancel()
        monitor = nil
        displayTimer?.invalidate()
        displayTimer = nil
        refreshTask?.cancel()
        refreshTask = nil
        socket?.removeAllHandlers()
        socket?.disconnect()
        socket = nil
        socketManager = nil
        socketConnected = false
        lastSocketEventAt = nil
        socketRetryAfter = .distantPast
        lastSnapshotAt = .distantPast
        progress.reset()
        pendingPlaybackState = nil
        currentInfo = nil
        currentTrackID = nil
    }

    func reconnect() {
        stop()
        rpc.endpoint = CiderEndpoint(host: preferences.ciderHost, port: preferences.ciderPort)
        start()
    }

    func refresh() {
        guard monitor != nil || generation > 0 else { return }
        guard refreshTask == nil else { refreshAgain = true; return }
        let requestGeneration = generation
        refreshTask = Task { [weak self] in
            guard let self else { return }
            defer {
                refreshTask = nil
                if refreshAgain { refreshAgain = false; refresh() }
            }
            do {
                let info = try await rpc.clientInfo()
                let snapshot = try await rpc.playback()
                guard requestGeneration == generation else { return }
                lastSnapshotAt = Date()
                rpcVersion = info["version"] as? String
                connection = .connected
                statusMessage = nil
                apply(snapshot)
                if socket == nil && Date() >= socketRetryAfter { connectSocket() }
            } catch let error as CiderRPCError {
                guard requestGeneration == generation else { return }
                switch error {
                case .unauthorized: connection = .authorizationRequired
                case .offline: connection = .offline
                default: connection = .failed(error.message)
                }
                currentInfo = nil
                currentTrackID = nil
                progress.reset()
                pendingPlaybackState = nil
                onPlayback?(nil, true)
            } catch {
                guard requestGeneration == generation else { return }
                connection = .failed("Could not read Cider playback.")
                currentTrackID = nil
                currentInfo = nil
                progress.reset()
                pendingPlaybackState = nil
                onPlayback?(nil, true)
            }
        }
    }

    private func apply(_ snapshot: CiderSnapshot) {
        if progress.shouldWaitForNewTrack(snapshot.trackID) {
            refreshAfterTransition()
            return
        }
        if let pendingPlaybackState, snapshot.trackID == currentTrackID,
           let info = snapshot.info, info.isPlaying != pendingPlaybackState.playing,
           Date() < pendingPlaybackState.until {
            refreshAfterTransition()
            return
        }
        pendingPlaybackState = nil
        let trackChanged = snapshot.trackID != currentTrackID
        let hadTrack = currentTrackID != nil
        if trackChanged && currentTrackID != nil && snapshot.trackID != nil {
            progress.markTrackChange()
        }
        currentTrackID = snapshot.trackID
        guard let info = snapshot.info else {
            progress.reset()
            currentInfo = nil
            onPlayback?(nil, trackChanged)
            return
        }
        let elapsed = progress.acceptSnapshot(trackID: snapshot.trackID, elapsed: info.currentTime,
                                              duration: info.totalTime, playing: info.isPlaying)
        publish(info, elapsed: elapsed, trackChanged: trackChanged)
        if trackChanged && hadTrack && snapshot.trackID != nil { refreshAfterTransition() }
    }

    private func publish(_ info: PlaybackInfo, elapsed: Double, trackChanged: Bool) {
        let updated = PlaybackInfo(artist: info.artist, title: info.title,
            isPlaying: info.isPlaying, imageURL: info.imageURL,
            totalTime: info.totalTime, currentTime: elapsed,
            image: info.image, isLiked: info.isLiked, longFormInfo: info.longFormInfo)
        currentInfo = updated
        onPlayback?(updated, trackChanged)
    }

    private func tickProgress() {
        guard let info = currentInfo, info.isPlaying else { return }
        let elapsed = progress.current()
        if abs(elapsed - info.currentTime) >= 0.25 {
            publish(info, elapsed: elapsed, trackChanged: false)
        }
    }

    private func refreshAfterTransition() {
        let requestGeneration = generation
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard let self, requestGeneration == self.generation else { return }
            self.refresh()
        }
    }

    private func suspendSilentSocket() {
        socket?.removeAllHandlers()
        socket?.disconnect()
        socket = nil
        socketManager = nil
        socketConnected = false
        lastSocketEventAt = nil
        socketRetryAfter = Date().addingTimeInterval(60)
    }

    private func connectSocket() {
        guard let url = rpc.endpoint.url else { return }
        let manager = SocketManager(socketURL: url, config: [
            .forceWebsockets(true), .reconnects(true), .reconnectWait(2), .handleQueue(.main)
        ])
        let client = manager.defaultSocket
        client.on(clientEvent: .connect) { [weak self] _, _ in
            self?.socketConnected = true
            self?.lastSocketEventAt = Date()
            self?.refresh()
        }
        client.on(clientEvent: .disconnect) { [weak self] _, _ in
            self?.socketConnected = false
        }
        client.on("API:Playback") { [weak self] data, _ in
            guard let event = data.first as? [String: Any], let type = event["type"] as? String else { return }
            self?.lastSocketEventAt = Date()
            switch type {
            case "playbackStatus.nowPlayingItemDidChange":
                if let self, let info = self.currentInfo {
                    self.progress.markTrackChange()
                    self.publish(info, elapsed: 0, trackChanged: false)
                }
                self?.refresh()
                self?.refreshAfterTransition()
            case "playbackStatus.playbackStateDidChange", "playbackStatus.transitionCompleted":
                self?.refresh()
            case "playbackStatus.playbackTimeDidChange":
                guard let payload = event["data"] as? [String: Any], let self,
                      let info = self.currentInfo else { return }
                let playing = payload["isPlaying"] as? Bool ?? info.isPlaying
                let time = payload["currentPlaybackTime"] as? Double
                let elapsed = self.progress.acceptTime(time ?? self.progress.current(), playing: playing)
                let updated = PlaybackInfo(artist: info.artist, title: info.title,
                    isPlaying: playing, imageURL: info.imageURL, totalTime: info.totalTime,
                    currentTime: info.currentTime, image: info.image, isLiked: info.isLiked,
                    longFormInfo: info.longFormInfo)
                self.publish(updated, elapsed: elapsed, trackChanged: false)
            default: break
            }
        }
        socketManager = manager
        socket = client
        client.connect()
    }

    func control(_ action: CiderAction) {
        guard connection == .connected else { return }
        Task { [weak self] in
            guard let self else { return }
            do {
                try await rpc.control(action)
                if let info = currentInfo {
                    switch action {
                    case .toggle:
                        let playing = !info.isPlaying
                        pendingPlaybackState = (playing, Date().addingTimeInterval(2))
                        let elapsed = progress.acceptTime(progress.current(), playing: playing)
                        let updated = PlaybackInfo(artist: info.artist, title: info.title,
                            isPlaying: playing, imageURL: info.imageURL,
                            totalTime: info.totalTime, currentTime: info.currentTime,
                            image: info.image, isLiked: info.isLiked, longFormInfo: info.longFormInfo)
                        publish(updated, elapsed: elapsed, trackChanged: false)
                    case .previous, .next:
                        progress.markTrackChange()
                        publish(info, elapsed: 0, trackChanged: false)
                    }
                }
                refreshAfterTransition()
            }
            catch let error as CiderRPCError { statusMessage = error.message; refresh() }
            catch { statusMessage = "Cider control failed." }
        }
    }

    func authorize() {
        guard !authorizationBusy else { return }
        authorizationBusy = true
        statusMessage = "Approve the access request in Cider."
        rpc.endpoint = CiderEndpoint(host: preferences.ciderHost, port: preferences.ciderPort)
        NSRunningApplication.runningApplications(withBundleIdentifier: "sh.cider.genten.mac")
            .first?.activate(options: [])
        Task { [weak self] in
            guard let self else { return }
            defer { authorizationBusy = false }
            do {
                let token = try await rpc.authorize()
                guard CiderTokenStore.save(token) else {
                    statusMessage = "Could not save authorization in Keychain."
                    return
                }
                rpc.token = token
                tokenLoaded = true
                statusMessage = nil
                reconnect()
            } catch let error as CiderRPCError { statusMessage = error.message }
            catch { statusMessage = "Authorization failed. Select Authorize to retry." }
        }
    }

    func saveManualToken(_ value: String) {
        let token = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !token.isEmpty else { return }
        guard CiderTokenStore.save(token) else {
            statusMessage = "Could not save authorization in Keychain."
            return
        }
        rpc.token = token
        tokenLoaded = true
        reconnect()
    }
}
