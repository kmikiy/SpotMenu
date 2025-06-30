import KeyboardShortcuts
import SwiftUI

enum MediaAction: String, CaseIterable, Identifiable {
    case playPause = "Play / Pause"
    case nextTrack = "Next Track"
    case previousTrack = "Previous Track"

    var id: String { self.rawValue }
    var shortcutName: KeyboardShortcuts.Name {
        switch self {
        case .playPause: return .playPause
        case .nextTrack: return .nextTrack
        case .previousTrack: return .previousTrack
        }
    }
}

struct ShortcutPreferencesView: View {
    @ObservedObject var model: PlaybackModel

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

            if model.isLikingEnabled {
                HStack {
                    Text("Toggle Like")
                        .frame(width: 150, alignment: .leading)
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .toggleLike)
                }
            }

            Spacer()
        }
        .padding(20)
        .frame(width: 400, height: model.isLikingEnabled ? 240 : 200)
    }
}

#Preview {
    ShortcutPreferencesView(
        model: PlaybackModel(preferences: PlayerPreferencesModel())
    )
}
