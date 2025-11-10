import SwiftUI

enum PreferencesSection: String, CaseIterable, Identifiable {
    case player = "Player"
    case appearance = "Appearance"
    case menuBar = "Menu Bar"
    case shortcuts = "Shortcuts"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .player:
            return "music.note"
        case .appearance:
            return "paintbrush"
        case .menuBar:
            return "menubar.rectangle"
        case .shortcuts:
            return "command"
        }
    }
}

struct PreferencesView: View {
    @ObservedObject var menuBarPreferencesModel: MenuBarPreferencesModel
    @ObservedObject var playbackModel: PlaybackModel
    @ObservedObject var musicPlayerPreferencesModel: MusicPlayerPreferencesModel
    @ObservedObject var playbackAppearancePreferencesModel:
        PlaybackAppearancePreferencesModel

    @State private var selectedSection: PreferencesSection? = .player

    var body: some View {
        NavigationSplitView {
            List(PreferencesSection.allCases, selection: $selectedSection) {
                section in
                Label(section.rawValue, systemImage: section.icon)
                    .tag(section)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 250)
            .listStyle(.sidebar)
            .safeAreaInset(edge: .top, spacing: 0) {
                // Extra space for traffic lights
                Color.clear.frame(height: 8)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                // Quit button at bottom of sidebar
                VStack(spacing: 0) {
                    Divider()
                    Button(action: {
                        NSApp.terminate(nil)
                    }) {
                        Label("Quit SpotMenu", systemImage: "power")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut("q", modifiers: [.command])
                }
                .background(Color(nsColor: .windowBackgroundColor))
            }
        } detail: {
            if let selectedSection = selectedSection {
                detailView(for: selectedSection)
                    .navigationTitle(selectedSection.rawValue)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(nsColor: .windowBackgroundColor))
                    .overlay(alignment: .top) {
                        LinearGradient(
                            colors: [
                                Color(nsColor: .windowBackgroundColor).opacity(
                                    1
                                ),
                                Color(nsColor: .windowBackgroundColor).opacity(
                                    0.90
                                ),
                                Color(nsColor: .windowBackgroundColor).opacity(
                                    0.0
                                ),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 60)
                        .allowsHitTesting(false)
                        .ignoresSafeArea(edges: .top)
                    }
            } else {
                Text("Select a section")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(nsColor: .windowBackgroundColor))
            }
        }
        .navigationSplitViewStyle(.balanced)
    }

    @ViewBuilder
    private func detailView(for section: PreferencesSection) -> some View {
        switch section {
        case .player:
            MusicPlayerPreferencesView(
                model: musicPlayerPreferencesModel,
                playbackModel: playbackModel
            )
        case .appearance:
            PlaybackAppearancePreferencesView(
                model: playbackAppearancePreferencesModel,
                musicPlayerPreferencesModel: musicPlayerPreferencesModel,
                playbackModel: playbackModel
            )
        case .menuBar:
            MenuBarPreferencesView(
                model: menuBarPreferencesModel,
                playbackModel: playbackModel,
                musicPlayerPreferencesModel: musicPlayerPreferencesModel
            )
        case .shortcuts:
            ShortcutPreferencesView(model: playbackModel, musicPlayerPreferencesModel: musicPlayerPreferencesModel)
        }
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
