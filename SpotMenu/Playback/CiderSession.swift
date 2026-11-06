import AppKit
import Foundation
import SocketIO

@MainActor
final class CiderSession: ObservableObject {
    @Published private(set) var connection: CiderConnection = .offline
    @Published var authorizationBusy = false
    @Published private(set) var rpcVersion: String?
    @Published var statusMessage: String?
    @Published private(set) var liveUpdates: CiderLiveUpdates = .checking
    @Published var libraryAuthorizationRequired = false

    var onPlayback: ((PlaybackInfo?, Bool) -> Void)?
    let preferences: MusicPlayerPreferencesModel
    let rpc: CiderRPC
    private var socketManager: SocketManager?
    private var socket: SocketIOClient?
    var monitor: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?
    var favoriteTask: Task<Void, Never>?
    private var favoriteRequestID = 0
    private var refreshAgain = false
    private var isRunning = false
    private var lastSocketEventAt: Date?
    private var eventCheckStartedAt = Date()
    private var lastRefreshAttemptAt = Date.distantPast
    private var lastSnapshotAt = Date.distantPast
    private var displayTimer: Timer?
    private var progress = CiderProgressClock()
    private var pendingPlaybackState: (playing: Bool, until: Date)?
    private var pendingSeek: (position: Double, until: Date)?
    private var favoriteStatus: Bool?
    var currentTrackID: String?
    private var currentInfo: PlaybackInfo?
    private var generation = 0
    var tokenLoaded = false

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
        isRunning = true
        liveUpdates = .checking
        eventCheckStartedAt = Date()
        displayTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tickProgress() }
        }
        refresh()
        monitor = Task { [weak self] in
            while let self, !Task.isCancelled {
                let now = Date()
                if self.liveUpdates != .unavailable,
                   CiderLiveUpdates.shouldMarkUnavailable(
                    isPlaying: self.currentInfo?.isPlaying == true,
                    lastEventAt: self.lastSocketEventAt,
                    checkingSince: self.eventCheckStartedAt, at: now) {
                    self.liveUpdates = .unavailable
                }
                let interval = self.liveUpdates.snapshotInterval(connected: self.connection == .connected)
                let lastCheck = self.liveUpdates == .active
                    ? self.lastSnapshotAt : self.lastRefreshAttemptAt
                if now.timeIntervalSince(lastCheck) >= interval {
                    self.refresh()
                }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }

    func stop() {
        generation += 1
        isRunning = false
        refreshAgain = false
        monitor?.cancel()
        monitor = nil
        displayTimer?.invalidate()
        displayTimer = nil
        refreshTask?.cancel()
        refreshTask = nil
        favoriteTask?.cancel()
        favoriteTask = nil
        socket?.removeAllHandlers()
        socket?.disconnect()
        socket = nil
        socketManager = nil
        lastSocketEventAt = nil
        liveUpdates = .checking
        lastRefreshAttemptAt = .distantPast
        lastSnapshotAt = .distantPast
        progress.reset()
        pendingPlaybackState = nil
        pendingSeek = nil
        favoriteStatus = nil
        currentInfo = nil
        currentTrackID = nil
    }

    func reconnect() {
        stop()
        rpc.endpoint = CiderEndpoint(host: preferences.ciderHost, port: preferences.ciderPort)
        start()
    }

    func refresh() {
        guard isRunning else { return }
        guard refreshTask == nil else { refreshAgain = true; return }
        lastRefreshAttemptAt = Date()
        let requestGeneration = generation
        refreshTask = Task { [weak self] in
            guard let self else { return }
            defer {
                if requestGeneration == generation {
                    refreshTask = nil
                    if refreshAgain { refreshAgain = false; refresh() }
                }
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
                if socket == nil { connectSocket() }
            } catch {
                guard requestGeneration == generation else { return }
                handleRefreshFailure(error)
            }
        }
    }

    private func handleRefreshFailure(_ error: Error) {
        if let rpcError = error as? CiderRPCError {
            switch rpcError {
            case .unauthorized: connection = .authorizationRequired
            case .offline: connection = .offline
            default: connection = .failed(rpcError.message)
            }
        } else {
            connection = .failed("Could not read Cider playback.")
        }
        currentInfo = nil
        currentTrackID = nil
        favoriteTask?.cancel()
        favoriteTask = nil
        favoriteStatus = nil
        progress.reset()
        pendingPlaybackState = nil
        pendingSeek = nil
        onPlayback?(nil, true)
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
        if let pendingSeek, snapshot.trackID == currentTrackID,
           let info = snapshot.info, abs(info.currentTime - pendingSeek.position) > 3,
           Date() < pendingSeek.until {
            refreshAfterTransition()
            return
        }
        pendingPlaybackState = nil
        pendingSeek = nil
        let trackChanged = snapshot.trackID != currentTrackID
        let hadTrack = currentTrackID != nil
        if trackChanged && currentTrackID != nil && snapshot.trackID != nil {
            progress.markTrackChange()
        }
        currentTrackID = snapshot.trackID
        if trackChanged {
            favoriteStatus = nil
            favoriteTask?.cancel()
            favoriteTask = nil
        }
        guard let info = snapshot.info else {
            progress.reset()
            currentInfo = nil
            onPlayback?(nil, trackChanged)
            return
        }
        let elapsed = progress.acceptSnapshot(trackID: snapshot.trackID, elapsed: info.currentTime,
                                              duration: info.totalTime, playing: info.isPlaying)
        publish(info, elapsed: elapsed, trackChanged: trackChanged)
        if trackChanged && !libraryAuthorizationRequired { refreshFavoriteStatus() }
        if trackChanged && hadTrack && snapshot.trackID != nil { refreshAfterTransition() }
    }

    private func publish(_ info: PlaybackInfo, elapsed: Double, trackChanged: Bool) {
        let updated = PlaybackInfo(artist: info.artist, title: info.title,
            isPlaying: info.isPlaying, imageURL: info.imageURL,
            totalTime: info.totalTime, currentTime: elapsed,
            image: info.image,
            isLiked: libraryAuthorizationRequired ? nil : (favoriteStatus ?? info.isLiked),
            longFormInfo: info.longFormInfo)
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
}

extension CiderSession {
    func refreshFavoriteStatus(initialDelay: Double = 0) {
        guard favoriteTask == nil, let trackID = currentTrackID else { return }
        let requestGeneration = generation
        favoriteRequestID += 1
        let requestID = favoriteRequestID
        favoriteTask = Task { [weak self] in
            guard let self else { return }
            defer {
                if requestGeneration == generation && requestID == favoriteRequestID {
                    favoriteTask = nil
                }
            }
            for delay in [initialDelay, 1.0, 2.0] {
                if delay > 0 { try? await Task.sleep(for: .seconds(delay)) }
                guard !Task.isCancelled, requestGeneration == generation,
                      trackID == currentTrackID else { return }
                do {
                    let favorite = try await rpc.favoriteStatus()
                    guard !Task.isCancelled, requestGeneration == generation,
                          trackID == currentTrackID else { return }
                    libraryAuthorizationRequired = false
                    setFavoriteStatus(favorite)
                } catch CiderRPCError.unauthorized {
                    libraryAuthorizationRequired = true
                    setFavoriteStatus(nil)
                    return
                } catch {
                    return
                }
            }
        }
    }

    func setFavoriteStatus(_ favorite: Bool?) {
        favoriteStatus = favorite
        guard let info = currentInfo else { return }
        publish(info, elapsed: progress.current(), trackChanged: false)
    }
}

extension CiderSession {
    private func connectSocket() {
        guard let url = rpc.endpoint.url else { return }
        let manager = SocketManager(socketURL: url, config: [
            .forceWebsockets(true), .reconnects(true), .reconnectWait(2), .handleQueue(.main)
        ])
        let client = manager.defaultSocket
        client.on(clientEvent: .connect) { [weak self] _, _ in
            self?.lastSocketEventAt = nil
            self?.eventCheckStartedAt = Date()
            self?.liveUpdates = .checking
            self?.refresh()
        }
        client.on(clientEvent: .disconnect) { [weak self] _, _ in
            self?.liveUpdates = .unavailable
        }
        client.on("API:Playback") { [weak self] data, _ in
            self?.handleSocketEvent(data)
        }
        socketManager = manager
        socket = client
        client.connect()
    }

    private func handleSocketEvent(_ data: [Any]) {
        guard let event = data.first as? [String: Any], let type = event["type"] as? String else { return }
        lastSocketEventAt = Date()
        liveUpdates = .active
        switch type {
        case "playbackStatus.nowPlayingItemDidChange":
            if let info = currentInfo {
                progress.markTrackChange()
                publish(info, elapsed: 0, trackChanged: false)
            }
            refresh()
            refreshAfterTransition()
        case "playbackStatus.playbackStateDidChange", "playbackStatus.transitionCompleted":
            refresh()
        case "playbackStatus.nowPlayingStatusDidChange":
            if let payload = event["data"] as? [String: Any],
               let favorite = payload["inFavorites"] as? Bool { setFavoriteStatus(favorite) }
        case "playbackStatus.playbackTimeDidChange":
            if let payload = event["data"] as? [String: Any] { handlePlaybackTimeEvent(payload) }
        default: break
        }
    }

    private func handlePlaybackTimeEvent(_ payload: [String: Any]) {
        guard let info = currentInfo else { return }
        let playing = payload["isPlaying"] as? Bool ?? info.isPlaying
        let time = payload["currentPlaybackTime"] as? Double
        if let pendingSeek, let time,
           abs(time - pendingSeek.position) > 3, Date() < pendingSeek.until { return }
        pendingSeek = nil
        let elapsed = progress.acceptTime(time ?? progress.current(), playing: playing)
        let updated = PlaybackInfo(artist: info.artist, title: info.title,
            isPlaying: playing, imageURL: info.imageURL, totalTime: info.totalTime,
            currentTime: info.currentTime, image: info.image, isLiked: info.isLiked,
            longFormInfo: info.longFormInfo)
        publish(updated, elapsed: elapsed, trackChanged: false)
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
            } catch let error as CiderRPCError {
                statusMessage = error.message
                refresh()
            } catch {
                statusMessage = "Cider control failed."
            }
        }
    }

    func seek(to seconds: Double) {
        guard connection == .connected, let info = currentInfo,
              seconds.isFinite, info.totalTime > 0 else { return }
        let position = min(max(0, seconds), info.totalTime)
        let trackID = currentTrackID
        Task { [weak self] in
            guard let self else { return }
            do {
                try await rpc.seek(to: position)
                guard trackID == currentTrackID, let info = currentInfo else { return }
                pendingSeek = (position, Date().addingTimeInterval(2))
                let elapsed = progress.acceptTime(position)
                publish(info, elapsed: elapsed, trackChanged: false)
                refreshAfterTransition()
            } catch let error as CiderRPCError {
                statusMessage = error.message
                refresh()
            } catch {
                statusMessage = "Cider seek failed."
                refresh()
            }
        }
    }
}
