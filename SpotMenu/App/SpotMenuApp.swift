import SwiftUI

@main
struct SpotMenuApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()  // No default window
        }
    }
}
