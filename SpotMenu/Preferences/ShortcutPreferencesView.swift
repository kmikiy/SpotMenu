import KeyboardShortcuts
import SwiftUI

enum MediaAction: String, CaseIterable, Identifiable {
    case playPause = "Play / Pause"
    case nextTrack = "Next Track"
    case previousTrack = "Previous Track"
    case showNowPlayingHUD = "Show Now Playing HUD"

    var id: String { self.rawValue }
    var shortcutName: KeyboardShortcuts.Name {
        switch self {
        case .playPause: return .playPause
        case .nextTrack: return .nextTrack
        case .previousTrack: return .previousTrack
        case .showNowPlayingHUD: return .showNowPlayingHUD
        }
    }
}

struct ShortcutPreferences: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Keyboard Shortcuts")
                .font(.title2)
                .bold()

            ForEach(MediaAction.allCases) { action in
                HStack {
                    Text(action.rawValue)
                        .frame(width: 150, alignment: .leading)
                    Spacer()
                    KeyboardShortcuts.Recorder(for: action.shortcutName)
                }
            }

            Spacer()
        }
        .padding(20)
        .frame(width: 400, height: 230)
    }
}

#Preview {
    ShortcutPreferences()
}
