import SwiftUI

struct PreferencesView: View {
    @ObservedObject var menuBarPreferencesModel: MenuBarPreferencesModel
    @ObservedObject var playbackModel: PlaybackModel
    @ObservedObject var musicPlayerPreferencesModel: MusicPlayerPreferencesModel
    @ObservedObject var playbackAppearancePreferencesModel:
        PlaybackAppearancePreferencesModel

    @State private var tabHeight: CGFloat = 0

    var body: some View {
        VStack(spacing: 16) {
            TabView {
                tabContainer {
                    MusicPlayerPreferencesView(
                        model: musicPlayerPreferencesModel,
                        playbackModel: playbackModel
                    )
                }
                .tabItem { Text("Player") }

                tabContainer {
                    PlaybackAppearancePreferencesView(
                        model: playbackAppearancePreferencesModel,
                        musicPlayerPreferencesModel: musicPlayerPreferencesModel,
                        playbackModel: playbackModel
                    )
                }
                .tabItem { Text("Appearance") }

                tabContainer {
                    MenuBarPreferencesView(
                        model: menuBarPreferencesModel,
                        playbackModel: playbackModel,
                        musicPlayerPreferencesModel: musicPlayerPreferencesModel
                    )
                }
                .tabItem { Text("Menu Bar") }

                tabContainer {
                    ShortcutPreferencesView(model: playbackModel, musicPlayerPreferencesModel: musicPlayerPreferencesModel)
                }
                .tabItem { Text("Shortcuts") }

            }
            .frame(height: tabHeight)
            .onPreferenceChange(TabHeightKey.self) { tabHeight = $0 }

            HStack {
                Spacer()
                Button(action: {
                    NSApp.terminate(nil)
                }) {
                    Label("Quit SpotMenu", systemImage: "power")
                        .labelStyle(.titleAndIcon)
                }
                .keyboardShortcut("q", modifiers: [.command])
                .buttonStyle(.borderless)
            }
            .padding(.top, 8)
        }
        .frame(width: 440)
        .padding()
    }

    private func tabContainer<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading) {
            content()
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(
                                key: TabHeightKey.self,
                                value: proxy.size.height
                            )
                    }
                )
        }
    }
}

private struct TabHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 100
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

#Preview {
    PreferencesView(
        menuBarPreferencesModel: MenuBarPreferencesModel(),
        playbackModel: PlaybackModel(
            preferences: MusicPlayerPreferencesModel()
        ),
        musicPlayerPreferencesModel: MusicPlayerPreferencesModel(),
        playbackAppearancePreferencesModel: PlaybackAppearancePreferencesModel()
    )
}
