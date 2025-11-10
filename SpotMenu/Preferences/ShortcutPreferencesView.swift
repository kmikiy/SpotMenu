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
                Form {
                    Section {
                        ForEach(MediaAction.allCases) { action in
                            HStack {
                                Text(action.rawValue)
                                Spacer()
                                KeyboardShortcuts.Recorder(for: action.shortcutName)
                            }
                        }
                    } header: {
                        Text("Playback Controls")
                    } footer: {
                        Text("Set keyboard shortcuts for controlling music playback.")
                    }
                }
                .formStyle(.grouped)
                .scrollContentBackground(.hidden)

                if model.isLikingImplemented
                    && musicPlayerPreferencesModel.likingEnabled
                {
                    Form {
                        Section {
                            HStack {
                                Text("Like Track")
                                Spacer()
                                KeyboardShortcuts.Recorder(for: .likeTrack)
                            }

                            HStack {
                                Text("Unlike Track")
                                Spacer()
                                KeyboardShortcuts.Recorder(for: .unlikeTrack)
                            }

                            HStack {
                                Text("Toggle Like")
                                Spacer()
                                KeyboardShortcuts.Recorder(for: .toggleLike)
                            }
                        } header: {
                            Text("Track Liking")
                        } footer: {
                            Text("Set keyboard shortcuts for liking and unliking tracks.")
                        }
                    }
                    .formStyle(.grouped)
                    .scrollContentBackground(.hidden)
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
