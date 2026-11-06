import AppKit
import Foundation

extension CiderSession {
    // The RPC acts on Cider's current song. Keep the response attached to the song
    // shown when the user clicked, so a late reply cannot change the next song's heart.
    func setFavorite(_ favorite: Bool) {
        guard connection == .connected, !libraryAuthorizationRequired,
              currentTrackID != nil else { return }
        let trackID = currentTrackID
        Task { [weak self] in
            guard let self else { return }
            do {
                try await rpc.setFavorite(favorite)
                guard trackID == currentTrackID else { return }
                setFavoriteStatus(favorite)
                favoriteTask?.cancel()
                favoriteTask = nil
                // Cider can publish its new rating after the control request returns.
                // Recheck the server so a delayed library update settles the displayed heart.
                refreshFavoriteStatus(initialDelay: 1)
            } catch CiderRPCError.unauthorized {
                libraryAuthorizationRequired = true
                setFavoriteStatus(nil)
            } catch let error as CiderRPCError {
                statusMessage = error.message
            } catch {
                statusMessage = "Cider favorite action failed."
            }
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
                libraryAuthorizationRequired = false
                if monitor == nil {
                    statusMessage = "Authorization saved. Select Cider as the preferred player to connect."
                } else {
                    statusMessage = nil
                    reconnect()
                }
            } catch let error as CiderRPCError {
                statusMessage = error.message
            } catch {
                statusMessage = "Authorization failed. Select Authorize to retry."
            }
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
        libraryAuthorizationRequired = false
        if monitor == nil {
            statusMessage = "Authorization saved. Select Cider as the preferred player to connect."
        } else {
            reconnect()
        }
    }
}
