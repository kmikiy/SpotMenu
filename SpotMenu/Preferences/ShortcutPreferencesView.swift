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
    @ObservedObject var musicPlayerPreferencesModel: MusicPlayerPreferencesModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(MediaAction.allCases) { action in
                HStack {
                    Text(action.rawValue)
                        .frame(width: 150, alignment: .leading)
                    Spacer()
                    KeyboardShortcuts.Recorder(for: action.shortcutName)
                }
            }

            if model.isLikingImplemented
                && musicPlayerPreferencesModel.likingEnabled
            {

                HStack {
                    Text("Like Track")
                        .frame(width: 150, alignment: .leading)
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .likeTrack)
                }

                HStack {
                    Text("Unlike Track")
                        .frame(width: 150, alignment: .leading)
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .unlikeTrack)
                }

                HStack {
                    Text("Toggle Like")
                        .frame(width: 150, alignment: .leading)
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .toggleLike)
                }

            }
        }
        .frame(maxWidth: 600)
        .padding(20)
    }
    }
}

#Preview {
    ShortcutPreferencesView(
        model: PlaybackModel(preferences: MusicPlayerPreferencesModel()),
        musicPlayerPreferencesModel: MusicPlayerPreferencesModel()
    )
}
