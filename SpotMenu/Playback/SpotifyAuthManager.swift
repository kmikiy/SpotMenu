import AppKit
import CryptoKit
import Foundation
import Security

class SpotifyAuthManager: ObservableObject {
    static let shared = SpotifyAuthManager()

    private let clientID = "de1b88ac8f8e4c209d8d9f326327a296"
    private let redirectURI = "com.github.kmikiy.spotmenu://callback"
    private let tokenURL = "https://accounts.spotify.com/api/token"
    private let authURL = "https://accounts.spotify.com/authorize"

    private let keychainService = "com.github.kmikiy.spotmenu.spotify.auth"
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    private let expiryDateKey = "tokenExpiry"
    private var codeVerifier: String?

    @Published var isAuthenticated = false

    // MARK: - Public Interface

    func startAuthentication() {
        codeVerifier = generateCodeVerifier()
        guard let codeVerifier = codeVerifier else { return }
        let codeChallenge = codeChallengeSHA256(codeVerifier)

        var components = URLComponents(string: authURL)!
        components.queryItems = [
            .init(name: "client_id", value: clientID),
            .init(name: "response_type", value: "code"),
            .init(name: "redirect_uri", value: redirectURI),
            .init(
                name: "scope",
                value: "user-library-read user-library-modify"
            ),
            .init(name: "code_challenge_method", value: "S256"),
            .init(name: "code_challenge", value: codeChallenge),
        ]

        if let url = components.url {
            NSWorkspace.shared.open(url)
        }
    }

    func handleRedirect(url: URL) {
        guard
            url.scheme == "com.github.kmikiy.spotmenu",
            let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "code" })?.value,
            let codeVerifier = codeVerifier
        else { return }

        requestAccessToken(code: code, codeVerifier: codeVerifier)
    }

    func getAccessToken(completion: @escaping (String?) -> Void) {
        guard let expiry = loadDate(key: expiryDateKey),
            expiry > Date(),
            let token = loadKeychain(key: accessTokenKey)
        else {
            refreshAccessToken(completion: completion)
            return
        }

        completion(token)
    }

    // MARK: - Spotify Liked Songs API

    func checkIfTrackIsLiked(
        trackID: String,
        completion: @escaping (Bool?) -> Void
    ) {
        getAccessToken { token in
            guard let token = token,
                let url = URL(
                    string:
                        "https://api.spotify.com/v1/me/tracks/contains?ids=\(trackID)"
                )
            else {
                completion(nil)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )

            URLSession.shared.dataTask(with: request) { data, _, _ in
                guard let data = data,
                    let result = try? JSONDecoder().decode(
                        [Bool].self,
                        from: data
                    ),
                    let isLiked = result.first
                else {
                    completion(nil)
                    return
                }
                completion(isLiked)
            }.resume()
        }
    }

    func addTrackToLiked(trackID: String, completion: ((Bool) -> Void)? = nil) {
        getAccessToken { token in
            guard let token = token,
                let url = URL(string: "https://api.spotify.com/v1/me/tracks")
            else {
                completion?(false)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )
            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )
            request.httpBody = try? JSONEncoder().encode(["ids": [trackID]])

            URLSession.shared.dataTask(with: request) { _, response, _ in
                let success = (response as? HTTPURLResponse)?.statusCode == 200
                completion?(success)
            }.resume()
        }
    }

    func removeTrackFromLiked(
        trackID: String,
        completion: ((Bool) -> Void)? = nil
    ) {
        getAccessToken { token in
            guard let token = token,
                let url = URL(string: "https://api.spotify.com/v1/me/tracks")
            else {
                completion?(false)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )
            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )
            request.httpBody = try? JSONEncoder().encode(["ids": [trackID]])

            URLSession.shared.dataTask(with: request) { _, response, _ in
                let success = (response as? HTTPURLResponse)?.statusCode == 200
                completion?(success)
            }.resume()
        }
    }

    // MARK: - Private Logic

    private func requestAccessToken(code: String, codeVerifier: String) {
        var request = URLRequest(url: URL(string: tokenURL)!)
        request.httpMethod = "POST"

        let bodyParams = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectURI,
            "client_id": clientID,
            "code_verifier": codeVerifier,
        ]

        request.httpBody =
            bodyParams
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)

        request.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data)
                    as? [String: Any],
                let accessToken = json["access_token"] as? String,
                let refreshToken = json["refresh_token"] as? String,
                let expiresIn = json["expires_in"] as? Double
            else {
                DispatchQueue.main.async { self.isAuthenticated = false }
                return
            }

            self.saveKeychain(key: self.accessTokenKey, value: accessToken)
            self.saveKeychain(key: self.refreshTokenKey, value: refreshToken)
            self.saveDate(
                key: self.expiryDateKey,
                value: Date().addingTimeInterval(expiresIn)
            )

            DispatchQueue.main.async {
                self.isAuthenticated = true
            }
        }.resume()
    }

    private func refreshAccessToken(completion: @escaping (String?) -> Void) {
        guard let refreshToken = loadKeychain(key: refreshTokenKey) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: URL(string: tokenURL)!)
        request.httpMethod = "POST"

        let bodyParams = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": clientID,
        ]

        request.httpBody =
            bodyParams
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)

        request.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data)
                    as? [String: Any],
                let accessToken = json["access_token"] as? String,
                let expiresIn = json["expires_in"] as? Double
            else {
                completion(nil)
                return
            }

            self.saveKeychain(key: self.accessTokenKey, value: accessToken)
            self.saveDate(
                key: self.expiryDateKey,
                value: Date().addingTimeInterval(expiresIn)
            )

            DispatchQueue.main.async {
                completion(accessToken)
            }
        }.resume()
    }

    // MARK: - PKCE Utility

    private func generateCodeVerifier() -> String {
        let bytes = [UInt8].random(count: 64)
        return Data(bytes).base64URLEncodedString()
    }

    private func codeChallengeSHA256(_ verifier: String) -> String {
        let data = Data(verifier.utf8)
        let hash = SHA256.hash(data: data)
        return Data(hash).base64URLEncodedString()
    }
}

// MARK: - Secure Storage Helpers

extension SpotifyAuthManager {
    private func saveKeychain(key: String, value: String) {
        #if DEBUG
            UserDefaults.standard.set(value, forKey: "dev.\(key)")
        #else
            let data = Data(value.utf8)
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: keychainService,
                kSecAttrAccount as String: key,
                kSecValueData as String: data,
                kSecAttrAccessible as String:
                    kSecAttrAccessibleAfterFirstUnlock,
            ]
            SecItemDelete(query as CFDictionary)
            SecItemAdd(query as CFDictionary, nil)
        #endif
    }

    private func loadKeychain(key: String) -> String? {
        #if DEBUG
            return UserDefaults.standard.string(forKey: "dev.\(key)")
        #else
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: keychainService,
                kSecAttrAccount as String: key,
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne,
            ]

            var result: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)

            if status == errSecSuccess,
                let data = result as? Data,
                let string = String(data: data, encoding: .utf8)
            {
                return string
            } else {
                return nil
            }
        #endif
    }

    private func saveDate(key: String, value: Date) {
        UserDefaults.standard.set(value, forKey: key)
    }

    private func loadDate(key: String) -> Date? {
        UserDefaults.standard.object(forKey: key) as? Date
    }
}

// MARK: - Utility Extensions

extension Data {
    func base64URLEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

extension Array where Element == UInt8 {
    static func random(count: Int) -> [UInt8] {
        (0..<count).map { _ in UInt8.random(in: 0...255) }
    }
}
