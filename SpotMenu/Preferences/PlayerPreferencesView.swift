import SwiftUI

struct PlayerPreferencesView: View {
    @ObservedObject var model: PlayerPreferencesModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Music Player")
                .font(.title2).bold()

            Picker(selection: $model.preferredPlayer) {
                ForEach(PreferredPlayer.allCases) { player in
                    Text(player.displayName).tag(player)
                }
            } label: {
                Text("Preferred Player")
            }
            .pickerStyle(.menu)

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
