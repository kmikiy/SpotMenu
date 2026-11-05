import Foundation
import SwiftUI

enum SpotifastSnapshot {
    static func parse(_ output: String) -> PlaybackInfo? {
        let fields = output.trimmingCharacters(in: .newlines)
            .components(separatedBy: "\t")
        guard fields.count >= 12, ["playing", "paused"].contains(fields[0]),
              let position = Double(fields[4]), position.isFinite, position >= 0,
              let duration = Double(fields[5]), duration.isFinite, duration > 0
        else { return nil }
        let liked: Bool?
        switch fields[10] {
        case "yes": liked = true
        case "no": liked = false
        default: liked = nil
        }
        return PlaybackInfo(artist: fields[2], title: fields[1],
            isPlaying: fields[0] == "playing",
            imageURL: fields[9].isEmpty ? nil : URL(string: fields[9]),
            totalTime: duration / 1000, currentTime: min(position, duration) / 1000,
            image: nil, isLiked: liked, longFormInfo: nil)
    }
}

enum SpotifastBridge {
    static func run(_ arguments: [String]) async throws -> String {
        let connection = NSXPCConnection(serviceName: SpotifastBridgeCommand.serviceName)
        connection.remoteObjectInterface = NSXPCInterface(with: SpotifastBridgeProtocol.self)
        connection.resume()
        defer { connection.invalidate() }
        return try await withCheckedThrowingContinuation { continuation in
            let proxyError = NSError(domain: "SpotifastBridge", code: 1,
                userInfo: [NSLocalizedDescriptionKey:
                    "Could not connect to the Spotifast helper. Restart SpotMenu and retry."])
            let proxy = connection.remoteObjectProxyWithErrorHandler { _ in
                continuation.resume(throwing: proxyError)
            } as? SpotifastBridgeProtocol
            guard let proxy else {
                continuation.resume(throwing: proxyError)
                return
            }
            proxy.execute(arguments) { output, message in
                if let output {
                    continuation.resume(returning: output)
                } else {
                    continuation.resume(throwing: NSError(domain: "SpotifastBridge", code: 2,
                        userInfo: [NSLocalizedDescriptionKey: message ?? "Could not read Spotifast playback."]))
                }
            }
        }
    }
}

@MainActor
final class SpotifastSession: ObservableObject {
    @Published private(set) var statusMessage: String?
    var onPlayback: ((PlaybackInfo?) -> Void)?
    private var monitor: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?
    private var controlTask: Task<Void, Never>?
    private var generation = 0
    private var commandVersion = 0

    func start() {
        guard monitor == nil else { return }
        monitor = Task { [weak self] in
            while !Task.isCancelled {
                self?.refresh()
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            }
        }
    }

    func stop() {
        generation += 1
        monitor?.cancel()
        monitor = nil
        refreshTask?.cancel()
        refreshTask = nil
        controlTask?.cancel()
        controlTask = nil
    }

    func refresh() {
        guard monitor != nil, refreshTask == nil, controlTask == nil else { return }
        let requestGeneration = generation
        let version = commandVersion
        refreshTask = Task { [weak self] in
            guard let self else { return }
            defer { if requestGeneration == generation { refreshTask = nil } }
            do {
                let output = try await SpotifastBridge.run(["now-playing", "--raw"])
                guard requestGeneration == generation, version == commandVersion else { return }
                statusMessage = nil
                onPlayback?(SpotifastSnapshot.parse(output))
            } catch {
                guard requestGeneration == generation, version == commandVersion else { return }
                statusMessage = error.localizedDescription
                onPlayback?(nil)
            }
        }
    }

    func control(_ arguments: [String], desiredLike: Bool? = nil) {
        guard monitor != nil else { return }
        commandVersion += 1
        let version = commandVersion
        let requestGeneration = generation
        let previous = controlTask
        controlTask = Task { [weak self] in
            await previous?.value
            guard let self, !Task.isCancelled, requestGeneration == generation else { return }
            defer {
                if requestGeneration == generation, version == commandVersion {
                    controlTask = nil
                    refresh()
                }
            }
            do {
                if let desiredLike {
                    let output = try await SpotifastBridge.run(["now-playing", "--raw"])
                    guard !Task.isCancelled, requestGeneration == generation,
                          let isLiked = SpotifastSnapshot.parse(output)?.isLiked,
                          isLiked != desiredLike else { return }
                }
                _ = try await SpotifastBridge.run(arguments)
                guard requestGeneration == generation else { return }
                statusMessage = nil
            } catch {
                guard requestGeneration == generation else { return }
                statusMessage = error.localizedDescription
            }
        }
    }

    func seek(to seconds: Double) {
        guard seconds.isFinite, seconds >= 0, seconds <= Double(UInt32.max) else { return }
        control(["seek-to", String(UInt32(seconds))])
    }
}
