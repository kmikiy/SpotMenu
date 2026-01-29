import SwiftUI

struct MusicPlayerPreferencesView: View {
    @ObservedObject var model: MusicPlayerPreferencesModel
    @ObservedObject var playbackModel: PlaybackModel
    @ObservedObject var spotifyAuthManager = SpotifyAuthManager.shared

    @State private var isTestingSpotifyConnection = false
    @State private var spotifyConnectionTestResult: Bool?
    @State private var showSpotifyConnectionTestResult = false
    @State private var isSpotifyAuthenticated = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Form {
                    Section {
                        Picker("Preferred Player", selection: $model.preferredMusicApp) {
                            ForEach(PreferredPlayer.allCases) { player in
                                Text(player.displayName).tag(player)
                            }
                        }
                    } header: {
                        Text("Music Player")
                    } footer: {
                        Text(
                            "\"Automatic\" selects the first available app at launch. If both Spotify and Apple Music are installed or running, Spotify is preferred."
                        )
                    }
                }
                .formStyle(.grouped)
                .scrollContentBackground(.hidden)

                if playbackModel.isLikingImplemented {
                    Form {
                        Section {
                            Toggle("Enable Track Liking", isOn: $model.likingEnabled)
                                .onChange(of: model.likingEnabled) { newValue in
                                    if newValue && !isSpotifyAuthenticated {
                                        LoginWindowManager.showLoginWindow(with: model)
                                    }
                                }

                            if model.likingEnabled {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Spotify Client ID")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    TextField(
                                        "Enter Spotify Client ID",
                                        text: Binding(
                                            get: { model.spotifyClientID ?? "" },
                                            set: { newValue in
                                                let trimmed = newValue.trimmingCharacters(
                                                    in: .whitespacesAndNewlines
                                                )
                                                model.spotifyClientID =
                                                    trimmed.isEmpty ? nil : trimmed
                                            }
                                        )
                                    )
                                    .textFieldStyle(.roundedBorder)
                                }

                                HStack {
                                    if showSpotifyConnectionTestResult {
                                        HStack(spacing: 6) {
                                            if isTestingSpotifyConnection {
                                                ProgressView()
                                                    .scaleEffect(0.5)
                                                Text("Testing")
                                            } else {
                                                Image(systemName: connectionStatusIcon)
                                                Text(connectionStatusText)
                                            }
                                        }
                                        .foregroundColor(connectionStatusColor)
                                        .font(.caption)
                                    }

                                    Spacer()

                                    Button("Test Connection") {
                                        testConnection()
                                    }
                                    .disabled(isTestingSpotifyConnection)

                                    if !isSpotifyAuthenticated {
                                        Button("Log In to Spotify") {
                                            LoginWindowManager.showLoginWindow(with: model)
                                        }
                                    }
                                }
                                .padding(.top, 8)
                            }
                        } header: {
                            Text("Spotify Integration")
                        } footer: {
                            Text("Enable liking tracks requires a Spotify Client ID. You can create one at developer.spotify.com.")
                        }
                    }
                    .formStyle(.grouped)
                    .scrollContentBackground(.hidden)
                }
            }
        .frame(maxWidth: 600)
        .padding(20)
    }
        .onAppear {
            SpotifyAuthManager.shared.checkAuthenticationStatus { isAuthed in
                DispatchQueue.main.async {
                    isSpotifyAuthenticated = isAuthed
                    spotifyConnectionTestResult = isAuthed
                    showSpotifyConnectionTestResult = true
                }
            }
        }
        .onChange(of: spotifyAuthManager.didAuthenticate) { newValue in
            if newValue {
                isSpotifyAuthenticated = true
                spotifyConnectionTestResult = true
                showSpotifyConnectionTestResult = true
            }
        }
    }

    private func testConnection() {
        isTestingSpotifyConnection = true
        spotifyConnectionTestResult = nil
        showSpotifyConnectionTestResult = true
        let start = Date()

        SpotifyAuthManager.shared.getAccessToken { token in
            let elapsed = Date().timeIntervalSince(start)
            let delay = max(0.5 - elapsed, 0)

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let isAuthed = token != nil
                self.spotifyConnectionTestResult = isAuthed
                self.isSpotifyAuthenticated = isAuthed
                self.isTestingSpotifyConnection = false
            }
        }
    }

    private var connectionStatusText: String {
        if isTestingSpotifyConnection {
            return "Testing"
        } else if let result = spotifyConnectionTestResult {
            return result ? "Connected" : "Not Connected"
        } else {
            return "Unknown"
        }
    }

    private var connectionStatusIcon: String {
        if isTestingSpotifyConnection {
            return "hourglass"
        } else if let result = spotifyConnectionTestResult {
            return result ? "checkmark.circle.fill" : "xmark.circle.fill"
        } else {
            return "questionmark.circle"
        }
    }

    private var connectionStatusColor: Color {
        if isTestingSpotifyConnection {
            return .gray
        }
        if let result = spotifyConnectionTestResult {
            return result ? .green : .red
        } else {
            return .gray
        }
    }
}

#Preview {
    MusicPlayerPreferencesView(
        model: MusicPlayerPreferencesModel(),
        playbackModel: PlaybackModel(preferences: MusicPlayerPreferencesModel())
    )
}
