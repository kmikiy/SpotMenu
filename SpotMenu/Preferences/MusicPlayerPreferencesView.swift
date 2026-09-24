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
                            "\"Automatic\" selects a running player first, then an installed player. " +
                            "Priority is Spotify, Apple Music, then Cider."
                        )
                    }
                }
                .formStyle(.grouped)
                .scrollContentBackground(.hidden)

                // Automatic may use either integration, so show each setup section there.
                if model.preferredMusicApp == .automatic || model.preferredMusicApp == .cider {
                    CiderPreferencesSection(model: model, cider: playbackModel.cider,
                                            isActive: playbackModel.playerType == .cider)
                }

                if model.preferredMusicApp == .automatic || model.preferredMusicApp == .spotify {
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
                            Text(
                                "Enable liking tracks requires a Spotify Client ID. " +
                                "You can create one at developer.spotify.com."
                            )
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

private struct CiderPreferencesSection: View {
    @ObservedObject var model: MusicPlayerPreferencesModel
    @ObservedObject var cider: CiderSession
    let isActive: Bool
    @State private var showManualToken = false
    @State private var manualToken = ""

    var body: some View {
        Form {
            Section("Cider Integration") {
                TextField("Host", text: $model.ciderHost)
                    .help("Loopback only: 127.0.0.1, localhost, or ::1")
                TextField("Port", value: $model.ciderPort, format: .number.grouping(.never))
                if isActive {
                    Text(cider.connection.message).foregroundStyle(.secondary)
                    if cider.connection == .connected {
                        switch cider.liveUpdates {
                        case .checking:
                            Text("Waiting for playback events to confirm WebSockets API")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        case .active:
                            Label("WebSocket playback updates active", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        case .unavailable:
                            EmptyView()
                        }
                    }
                } else {
                    Text("Select Cider as the preferred player to check its connection.")
                        .foregroundStyle(.secondary)
                }
                if isActive && cider.connection == .connected && cider.liveUpdates == .unavailable {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Live playback updates are unavailable", systemImage: "exclamationmark.triangle")
                        Text(
                            "In Cider, open Settings → Connections → External Applications " +
                            "and enable WebSockets API. SpotMenu checks playback about every " +
                            "two seconds until live updates return."
                        )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack {
                            Button("Open Cider") { openApp(bundleIdentifier: "sh.cider.genten.mac") }
                            Button("Check Again") { cider.reconnect() }
                        }
                    }
                }
                if isActive && cider.libraryAuthorizationRequired {
                    Text("Approve SpotMenu again in Cider to enable favorites. The new request adds library access.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if isActive, let version = cider.rpcVersion {
                    Text("RPC version \(version)").font(.caption).foregroundStyle(.secondary)
                }
                if let message = cider.statusMessage {
                    Text(message).font(.caption).foregroundStyle(.secondary)
                }
                HStack {
                    Button(isActive && cider.connection == .connected ? "Reauthorize in Cider" : "Authorize in Cider") {
                        cider.authorize()
                    }
                        .help("SpotMenu stores Cider's playback and library token in macOS Keychain.")
                        .disabled(cider.authorizationBusy)
                    if cider.authorizationBusy { ProgressView().controlSize(.small) }
                    if isActive { Button("Retry Connection") { cider.reconnect() } }
                }
                DisclosureGroup("Enter token manually", isExpanded: $showManualToken) {
                    SecureField("Cider RPC token", text: $manualToken)
                    Button("Save Token") {
                        cider.saveManualToken(manualToken)
                        manualToken = ""
                    }
                    .disabled(manualToken.isEmpty)
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    MusicPlayerPreferencesView(
        model: MusicPlayerPreferencesModel(),
        playbackModel: PlaybackModel(preferences: MusicPlayerPreferencesModel())
    )
}
