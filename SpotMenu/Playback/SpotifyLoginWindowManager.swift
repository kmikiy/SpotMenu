import SwiftUI

class LoginWindowManager {
    static var loginWindow: NSWindow?

    static func showLoginWindow(with preferences: MusicPlayerPreferencesModel){
        guard loginWindow == nil else {
            loginWindow?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let view = SpotifyLoginView(preferences: preferences)
        let hosting = NSHostingView(rootView: view)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 320),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.contentView = hosting
        window.title = "Log In to Spotify"
        window.isReleasedWhenClosed = false
        loginWindow = window

        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
