import SwiftUI

struct StatusItemView: View {
    @ObservedObject var model: StatusItemModel
    @ObservedObject var menuBarPreferencesModel: MenuBarPreferencesModel
    @ObservedObject var musicPlayerPreferencesModel: MusicPlayerPreferencesModel
    @ObservedObject var playbackModel: PlaybackModel

    var body: some View {
        content
            .frame(maxWidth: menuBarPreferencesModel.maxStatusItemWidth)
            .padding(.horizontal, 0)
            .padding(.vertical, 2)
            .background(Color.clear)
            .lineLimit(1)
            .truncationMode(.tail)
    }

    private var content: some View {
        let displayOptions = model.computeDisplayOptions(
            menuBarPreferencesModel: menuBarPreferencesModel,
            musicPlayerPreferencesModel: musicPlayerPreferencesModel,
            playbackModel: playbackModel
        )

        return HStack(spacing: 4) {
            if displayOptions.showIcon {
                Image(model.playerIconName)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .clipShape(Circle())
            }

            if displayOptions.showHeartIcon {
                Image(systemName: "heart.fill")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 13, height: 13)
                    .transition(.opacity)
            }

            if displayOptions.showMusicIcon {
                Text("♫").font(.system(size: 13))
            }

            if displayOptions.showText {
                if displayOptions.showCompact {
                    VStack(spacing: -2) {
                        if displayOptions.showArtist {
                            Text(model.artist)
                                .font(.system(size: 10, weight: menuBarPreferencesModel.fontWeightCompactTop.fontWeight))
                        }
                        if displayOptions.showTitle {
                            Text(model.title)
                                .font(.system(size: 9, weight: menuBarPreferencesModel.fontWeightCompactBottom.fontWeight))
                        }
                    }

                } else {
                    Text(
                        model.buildText(
                            displayOptions: displayOptions,
                            font: NSFont.systemFont(ofSize: 13),
                        )
                    )
                    .font(.system(size: 13, weight: menuBarPreferencesModel.fontWeightNormal.fontWeight))
                }

            }
        }
    }
}

#Preview {
    let model = StatusItemModel()
    model.artist = "test"
    model.title =
        "very long text that should be truncated very very long text"
    model.isPlaying = true

    let preferences = MenuBarPreferencesModel()
    preferences.showArtist = true
    preferences.showTitle = true
    preferences.showIsPlayingIcon = true
    preferences.compactView = false

    let playbackModel = PlaybackModel(
        preferences: MusicPlayerPreferencesModel()
    )
    return StatusItemView(
        model: model,
        menuBarPreferencesModel: preferences,
        musicPlayerPreferencesModel: MusicPlayerPreferencesModel(),
        playbackModel: playbackModel
    )
}
