import SwiftUI

struct MusicPlayerPreferencesView: View {
    @ObservedObject var model: MusicPlayerPreferencesModel
    @ObservedObject var playbackModel: PlaybackModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Music Player")
                .font(.title2).bold()

            HStack {
                Text("Preferred Player")
                Spacer()
                Picker(selection: $model.preferredMusicApp) {
                    ForEach(PreferredPlayer.allCases) { player in
                        Text(player.displayName).tag(player)
                    }
                } label: {
                }
                .pickerStyle(.menu)
                .frame(maxWidth: 120)
            }

            Text(
                "“Automatic” selects the first available app at launch. If both Spotify and Apple Music are installed or running, Spotify is preferred."
            )
            .font(.caption)
            .foregroundColor(.secondary)

            if playbackModel.isLikingImplemented {
                HStack {
                    Text("Enable Track Liking")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Toggle("", isOn: $model.likingEnabled)
                        .toggleStyle(.switch)
                        .controlSize(.small)
                }
                if model.likingEnabled {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Spotify Client ID")
                            TextField(
                                "Enter Spotify Client ID",
                                text: Binding(
                                    get: { model.spotifyClientID ?? "" },
                                    set: { newValue in
                                        model.spotifyClientID =
                                            newValue.trimmingCharacters(
                                                in: .whitespacesAndNewlines
                                            ).isEmpty ? nil : newValue
                                    }
                                )
                            )
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 12))
                        }
                    }
                }

            }

            Spacer()
        }
        .padding(20)
        .frame(width: 400, height: 260)
    }
}

#Preview {
    MusicPlayerPreferencesView(
        model: MusicPlayerPreferencesModel(),
        playbackModel: PlaybackModel(preferences: MusicPlayerPreferencesModel())
    )
}
