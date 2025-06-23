import SwiftUI

struct PlayerPreferencesView: View {
    @ObservedObject var model: PlayerPreferencesModel
    @State private var selectedPlayer: PreferredPlayer

    init(model: PlayerPreferencesModel) {
        self.model = model
        _selectedPlayer = State(initialValue: model.preferredPlayer)
    }

    var body: some View {
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
                .onChange(of: selectedPlayer) {
                    model.preferredPlayer = selectedPlayer
                }

            }

            Text(
                "“Automatic” selects the first available app at launch. If both Spotify and Apple Music are installed or running, Spotify is preferred."
            )
            .font(.caption)
            .foregroundColor(.secondary)

            Spacer()
        }
        .padding(20)
        .frame(width: 400, height: 200)
    }
}

#Preview {
    PlayerPreferencesView(model: .init())
}
