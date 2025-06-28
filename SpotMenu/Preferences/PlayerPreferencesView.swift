import SwiftUI

struct PlayerPreferencesView: View {
    @ObservedObject var model: PlayerPreferencesModel
    @State private var selectedPlayer: PreferredPlayer

    init(model: PlayerPreferencesModel) {
        self.model = model
        _selectedPlayer = State(initialValue: model.preferredMusicApp)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // MARK: Player Selection Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Music Player")
                    .font(.title2).bold()

                HStack {
                    Text("Preferred Player")
                    Spacer()
                    Picker(selection: $selectedPlayer) {
                        ForEach(PreferredPlayer.allCases) { player in
                            Text(player.displayName).tag(player)
                        }
                    } label: {
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: 120)
                    .onChange(of: selectedPlayer) { newValue in
                        DispatchQueue.main.async {
                            model.preferredMusicApp = newValue
                        }
                    }
                }

                Text(
                    "“Automatic” selects the first available app at launch. If both Spotify and Apple Music are installed or running, Spotify is preferred."
                )
                .font(.caption)
                .foregroundColor(.secondary)
            }

            // MARK: Playback Appearance Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Playback Appearance")
                    .font(.title2).bold()

                HStack {
                    Text("Hover Tint Color")
                    Spacer()
                    ColorPicker(
                        "",
                        selection: Binding(
                            get: { Color(model.hoverTintColor) },
                            set: { model.hoverTintColor = NSColor($0) }
                        )
                    )
                }
                
                HStack {
                    Text("Foreground Color")
                    Spacer()
                    Picker("", selection: $model.foregroundColor) {
                        ForEach(PlayerPreferencesModel.ForegroundColorOption.allCases) { option in
                            Text(option.rawValue.capitalized).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 100)
                }

                HStack {
                    Text("Blur Intensity")
                    Spacer()
                    Slider(value: $model.blurIntensity, in: 0...1)
                        .frame(width: 220)
                }

                // MARK: Live-updating Playback Preview
                Spacer()
                HStack {
                    Spacer()
                    PlaybackView(
                        model: PlaybackModel(preferences: model),
                        preferences: model
                    )
                    Spacer()
                }
            }
        }
        .padding(20)
        .frame(width: 400, height: 640)
    }
}

#Preview {
    PlayerPreferencesView(model: .init())
}
