import Foundation
import Sparkle

/// Shared Sparkle updater controller - must be a single instance app-wide
final class UpdaterManager {
    static let shared = UpdaterManager()

    let controller: SPUStandardUpdaterController
    var updater: SPUUpdater { controller.updater }

    private init() {
        controller = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )

        // Enable automatic update checks by default on first launch
        // Menu bar apps don't reliably show Sparkle's permission prompt
        if !UserDefaults.standard.bool(forKey: "hasConfiguredSparkle") {
            controller.updater.automaticallyChecksForUpdates = true
            UserDefaults.standard.set(true, forKey: "hasConfiguredSparkle")
        }
    }
}
