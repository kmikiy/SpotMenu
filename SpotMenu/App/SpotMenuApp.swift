import SwiftUI

@main
struct SpotMenuApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Empty WindowGroup is needed for menu bar apps
        // We handle windows manually through managers
        WindowGroup {
            EmptyView()
                .frame(width: 0, height: 0)
                .hidden()
        }
        .commands {
            // Replace default Settings command with our custom implementation
            CommandGroup(replacing: .appSettings) {
                Button("Preferences...") {
                    appDelegate.preferencesAction()
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
        // Disable automatic window creation
        .defaultSize(width: 0, height: 0)
    }
}
