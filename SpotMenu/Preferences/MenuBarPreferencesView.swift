import SwiftUI

struct MenuBarPreferencesView: View {
    @ObservedObject var model: MenuBarPreferencesModel
    @ObservedObject var playbackModel: PlaybackModel
    @ObservedObject var musicPlayerPreferencesModel: MusicPlayerPreferencesModel
    @State private var isSpotifyAuthenticated = false

    @StateObject private var previewModel: StatusItemModel = {
        let model = StatusItemModel()
        model.artist = "Lorem Ipsum"
        model.title = "Ut Sit Amet Justo Efficitur, Imperdiet Elit Sit Amet"
        model.isPlaying = true
        model.isLiked = true
        return model
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Menu Bar Settings")
                .font(.title2.bold())

            // TEXT DISPLAY SECTION
            VStack(alignment: .leading, spacing: 8) {
                Text("Text Display")
                    .font(.headline)

                settingsRow(
                    "Display Artist",
                    binding: Binding(
                        get: { model.showArtist },
                        set: { newValue in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                model.showArtist = newValue
                            }
                        }
                    )
                )

                if model.showArtist {
                    settingsRow(
                        "Hide When Paused",
                        binding: $model.hideArtistWhenPaused
                    )
                    .padding(.leading, 24)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                settingsRow(
                    "Display Song Title",
                    binding: Binding(
                        get: { model.showTitle },
                        set: { newValue in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                model.showTitle = newValue
                            }
                        }
                    )
                )

                if model.showTitle {
                    VStack(alignment: .leading, spacing: 0) {
                        settingsRow(
                            "Hide When Paused",
                            binding: $model.hideTitleWhenPaused
                        )
                    }
                    .padding(.leading, 24)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }

            // ICON DISPLAY SECTION
            VStack(alignment: .leading, spacing: 12) {
                Text("Icons")
                    .font(.headline)

                VStack(spacing: 8) {
                    settingsRow(
                        "Show Playing Icon",
                        binding: $model.showIsPlayingIcon
                    )

                    if playbackModel.isLikingImplemented
                        && musicPlayerPreferencesModel.likingEnabled
                    {
                        settingsRow(
                            "Show Liked Icon",
                            binding: Binding(
                                get: { model.showIsLikedIcon },
                                set: { newValue in
                                    model.showIsLikedIcon = newValue

                                    if newValue
                                        && !isSpotifyAuthenticated
                                    {
                                        LoginWindowManager.showLoginWindow(
                                            with: musicPlayerPreferencesModel
                                        )
                                    }
                                }
                            )
                        )
                    }

                    settingsRow(
                        "Display App Icon",
                        binding: Binding(
                            get: { model.showAppIcon },
                            set: { newValue in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    model.showAppIcon = newValue
                                }
                            }
                        )
                    )
                    // FALLBACK NOTE
                    if !model.showAppIcon {
                        Text(
                            "If nothing is currently visible based on your settings and playback status, the app icon will be shown as a fallback even if 'Display App Icon' is turned off."
                        )
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                }

            }

            // LAYOUT SECTION
            VStack(alignment: .leading, spacing: 12) {
                Text("Layout")
                    .font(.headline)

                VStack(spacing: 8) {
                    settingsRow("Compact View", binding: $model.compactView)

                    HStack {
                        Text("Max Width")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Slider(
                            value: $model.maxStatusItemWidth,
                            in: 40...300,
                            step: 1
                        )
                        .frame(width: 220)
                        Text("\(Int(model.maxStatusItemWidth)) pt")
                            .frame(width: 50)
                    }
                }
            }

            // PREVIEW SECTION
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                Text("Status Item Preview")
                    .font(.headline)

                StatusItemView(
                    model: previewModel,
                    menuBarPreferencesModel: model,
                    musicPlayerPreferencesModel: musicPlayerPreferencesModel,
                    playbackModel: playbackModel
                )
                .frame(width: model.maxStatusItemWidth, height: 22)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                        .foregroundColor(.gray.opacity(0.4))
                )
                .frame(maxWidth: .infinity, alignment: .center)

                Text(
                    "Maximum width shown. Actual width may be smaller depending on content."
                )
                .font(.caption2)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(20)
        .frame(width: 400, height: calculateHeight())
        .onAppear {
            SpotifyAuthManager.shared.checkAuthenticationStatus {
                self.isSpotifyAuthenticated = $0
            }
        }
    }

    private func calculateHeight() -> CGFloat {
        var height = 600.0

        if playbackModel.isLikingImplemented
            && musicPlayerPreferencesModel.likingEnabled
        {
            height = height + 30
        }

        return height
    }

    @ViewBuilder
    private func settingsRow(_ title: String, binding: Binding<Bool>)
        -> some View
    {
        HStack {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
            Toggle("", isOn: binding)
                .toggleStyle(.switch)
                .controlSize(.small)
        }
    }
}

#Preview {
    MenuBarPreferencesView(
        model: MenuBarPreferencesModel(),
        playbackModel: PlaybackModel(
            preferences: MusicPlayerPreferencesModel()
        ),
        musicPlayerPreferencesModel: MusicPlayerPreferencesModel()
    )
}
