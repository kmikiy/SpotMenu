import AppKit
import Foundation

// An embedded XPC service has its own sandbox policy. This service needs the
// user's real temporary directory to reach Spotifast's private control socket.
// SpotMenu itself retains App Sandbox. No shell or caller-supplied path is used.
final class SpotifastService: NSObject, NSXPCListenerDelegate, SpotifastBridgeProtocol {
    private let commands = DispatchQueue(label: "SpotifastBridge.commands")

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
        connection.exportedInterface = NSXPCInterface(with: SpotifastBridgeProtocol.self)
        connection.exportedObject = self
        connection.resume()
        return true
    }

    func execute(_ arguments: [String], reply: @escaping (String?, String?) -> Void) {
        guard SpotifastBridgeCommand.isAllowed(arguments) else {
            reply(nil, "Unsupported Spotifast command.")
            return
        }
        commands.async {
            guard
                let app = NSWorkspace.shared.urlForApplication(
                    withBundleIdentifier: "rocks.spotifast.Spotifast"
                ), let executable = Bundle(url: app)?.executableURL
            else {
                reply(nil, "Install Spotifast to use this player.")
                return
            }
            let process = Process()
            process.executableURL = executable
            process.arguments = arguments
            // XPC may inherit the host's TMPDIR. Use the service's unsandboxed
            // per-user directory, which is where Spotifast puts its socket.
            var buffer = [CChar](repeating: 0, count: Int(PATH_MAX))
            guard confstr(_CS_DARWIN_USER_TEMP_DIR, &buffer, buffer.count) > 0 else {
                reply(nil, "Could not locate Spotifast's control channel.")
                return
            }
            var environment = ProcessInfo.processInfo.environment
            environment["TMPDIR"] = String(cString: buffer)
            process.environment = environment
            let output = Pipe()
            process.standardOutput = output
            process.standardError = FileHandle.nullDevice
            do {
                try process.run()
                let timeout = DispatchWorkItem { if process.isRunning { process.terminate() } }
                DispatchQueue.global().asyncAfter(deadline: .now() + 4, execute: timeout)
                let data = output.fileHandleForReading.readDataToEndOfFile()
                process.waitUntilExit()
                timeout.cancel()
                guard process.terminationStatus == 0 else {
                    reply(nil, "Open Spotifast 0.17.1 or later and start a track, then retry.")
                    return
                }
                reply(String(data: data, encoding: .utf8), nil)
            } catch {
                reply(nil, "Could not run Spotifast's playback command.")
            }
        }
    }
}

let delegate = SpotifastService()
let listener = NSXPCListener.service()
listener.delegate = delegate
listener.resume()
