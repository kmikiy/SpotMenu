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
                        .onChange(of: model.likingEnabled) {
                            if model.likingEnabled && !isSpotifyAuthenticated {
                                LoginWindowManager.showLoginWindow(with: model)
                            }
                        }
                }

                if model.likingEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Spotify Client ID")
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
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 12))
                    }

                    // Spotify Connection Status Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Spacer()
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
                                .frame(height: 6)
                            }

                            Button("Test") {
                                testConnection()
                            }
                            .disabled(isTestingSpotifyConnection)

                            if !isSpotifyAuthenticated {
                                Button("Log In to Spotify") {
                                    LoginWindowManager.showLoginWindow(
                                        with: model
                                    )
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                }
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
        .onChange(of: spotifyAuthManager.didAuthenticate) { _, newValue in
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
