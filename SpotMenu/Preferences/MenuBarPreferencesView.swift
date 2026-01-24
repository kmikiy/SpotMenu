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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Form {
                    Section {
                        Toggle("Display Artist", isOn: Binding(
                            get: { model.showArtist },
                            set: { newValue in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    model.showArtist = newValue
                                }
                            }
                        ))

                        if model.showArtist {
                            Toggle("Hide Artist When Paused", isOn: $model.hideArtistWhenPaused)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        Toggle("Display Title", isOn: Binding(
                            get: { model.showTitle },
                            set: { newValue in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    model.showTitle = newValue
                                }
                            }
                        ))

                        if model.showTitle {
                            Picker(
                                "Long-form Content",
                                selection: $musicPlayerPreferencesModel
                                    .longFormTitleStyle
                            ) {
                                ForEach(
                                    LongFormTitleStyle.allCases,
                                    id: \.self
                                ) { style in
                                    Text(style.displayName).tag(style)
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            
                            Toggle("Hide Title When Paused", isOn: $model.hideTitleWhenPaused)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    } header: {
                        Text("Text Display")
                    } footer: {
                        Text("Choose which text information to display in the menu bar.")
                    }
                }
                .formStyle(.grouped)
                .scrollContentBackground(.hidden)

                Form {
                    Section {
                        Toggle("Show Playing Icon", isOn: $model.showIsPlayingIcon)

                        if playbackModel.isLikingImplemented
                            && musicPlayerPreferencesModel.likingEnabled
                        {
                            Toggle("Show Liked Icon", isOn: Binding(
                                get: { model.showIsLikedIcon },
                                set: { newValue in
                                    model.showIsLikedIcon = newValue
                                    if newValue && !isSpotifyAuthenticated {
                                        LoginWindowManager.showLoginWindow(
                                            with: musicPlayerPreferencesModel
                                        )
                                    }
                                }
                            ))
                        }

                        Toggle("Display App Icon", isOn: Binding(
                            get: { model.showAppIcon },
                            set: { newValue in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    model.showAppIcon = newValue
                                }
                            }
                        ))
                    } header: {
                        Text("Icons")
                    } footer: {
                        if !model.showAppIcon {
                            Text(
                                "If nothing is currently visible based on your settings and playback status, the app icon will be shown as a fallback."
                            )
                        } else {
                            Text("Choose which icons to display in the menu bar.")
                        }
                    }
                }
                .formStyle(.grouped)
                .scrollContentBackground(.hidden)

                Form {
                    Section {
                        Toggle("Compact View", isOn: $model.compactView)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Max Width")
                                Spacer()
                                Text("\(Int(model.maxStatusItemWidth)) pt")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                            Slider(
                                value: $model.maxStatusItemWidth,
                                in: 40...300,
                                step: 1
                            )
                        }
                    } header: {
                        Text("Layout")
                    } footer: {
                        Text("Adjust the maximum width for the menu bar item.")
                    }
                }
                .formStyle(.grouped)
                .scrollContentBackground(.hidden)

                Form {
                    Section {
                        if model.compactView {
                            Picker("Font weight (top row)", selection: $model.fontWeightCompactTop) {
                                ForEach(MenuBarFontWeight.allCases, id: \.self) { weight in
                                    Text(weight.rawValue.capitalized).tag(weight)
                                }
                            }

                            Picker("Font weight (bottom row)", selection: $model.fontWeightCompactBottom) {
                                ForEach(MenuBarFontWeight.allCases, id: \.self) { weight in
                                    Text(weight.rawValue.capitalized).tag(weight)
                                }
                            }
                        } else {
                            Picker("Font weight", selection: $model.fontWeightNormal) {
                                ForEach(MenuBarFontWeight.allCases, id: \.self) { weight in
                                    Text(weight.rawValue.capitalized).tag(weight)
                                }
                            }
                        }
                    } header: {
                        Text("Font Weights")
                    } footer: {
                        if model.compactView {
                            Text("Adjust font weights for the top and bottom rows in compact view.")
                        } else {
                            Text("Adjust font weight for menu bar text in normal view.")
                        }
                    }
                }
                .formStyle(.grouped)
                .scrollContentBackground(.hidden)

                Form {
                    Section {
                        VStack(spacing: 8) {
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
                        }
                    } header: {
                        Text("Preview")
                    } footer: {
                        Text("Maximum width shown. Actual width may be smaller depending on content.")
                    }
                }
                .formStyle(.grouped)
                .scrollContentBackground(.hidden)
            }
        .frame(maxWidth: 600)
        .padding(20)
    }
        .onAppear {
            SpotifyAuthManager.shared.checkAuthenticationStatus {
                self.isSpotifyAuthenticated = $0
            }
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
