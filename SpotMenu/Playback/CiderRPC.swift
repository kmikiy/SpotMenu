import Foundation
import Security

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
        configuration.timeoutIntervalForRequest = 90
        self.session = session ?? URLSession(
            configuration: configuration,
            delegate: CiderNoRedirect(),
            delegateQueue: nil
        )
    }

    func clientInfo() async throws -> [String: Any] { try await request("client/info") }
    func playback() async throws -> CiderSnapshot { CiderSnapshot.parse(try await request("playback")) }

    func control(_ action: CiderAction) async throws {
        _ = try await request("playback/\(action.rawValue)", method: "POST",
                              body: action == .previous ? ["force": false] : nil)
    }

    func seek(to seconds: Double) async throws {
        guard seconds.isFinite, seconds >= 0 else { throw CiderRPCError.invalidResponse }
        _ = try await request("playback/seek", method: "POST", body: ["position": seconds])
    }

    func favoriteStatus() async throws -> Bool {
        let result = try await request("library/now-playing/status")
        guard let rating = result["rating"] as? Int else { throw CiderRPCError.invalidResponse }
        return rating == 1
    }

    func setFavorite(_ favorite: Bool) async throws {
        if favorite {
            _ = try await request("library/now-playing/love", method: "POST")
        } else {
            _ = try await request("library/now-playing/rating", method: "DELETE")
        }
    }

    func authorize() async throws -> String {
        let result = try await request("auth/request", method: "POST",
                                       body: ["app_name": "SpotMenu", "scopes": ["playback", "library"]],
                                       authenticated: false, timeout: 90)
        guard let token = result["token"] as? String, !token.isEmpty else { throw CiderRPCError.invalidResponse }
        guard let scopes = result["scopes"] as? [String],
              scopes.contains("playback"), scopes.contains("library") else {
            throw CiderRPCError.denied
        }
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
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            if error.code == .timedOut && !authenticated { throw CiderRPCError.timedOut }
            throw CiderRPCError.offline
        }
        return try decode(data, response: response, authenticated: authenticated)
    }

    private func decode(_ data: Data, response: URLResponse, authenticated: Bool) throws -> [String: Any] {
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
            isLiked: fields["inFavorites"] as? Bool ?? item["inFavorites"] as? Bool,
            longFormInfo: nil))
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
