import SwiftUI

struct StatusItemView: View {
    @ObservedObject var model: StatusItemModel
    @ObservedObject var menuBarPreferencesModel: MenuBarPreferencesModel
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
        let showIcon = StatusItemDisplayHelper.shouldShowAppIcon(
            preferences: menuBarPreferencesModel,
            model: model
        )

        return HStack(spacing: 4) {
            if showIcon {
                Image(playbackModel.playerIconName)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .clipShape(Circle())
            }
            
            if model.isLiked == true {
                Image(systemName: "heart.fill")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 13, height: 13)
                    .transition(.opacity)
            }

            if menuBarPreferencesModel.showIsPlayingIcon && model.isPlaying {
                Text("♫").font(.system(size: 13))
            }

            if menuBarPreferencesModel.compactView {
                if !model.isTextEmpty && menuBarPreferencesModel.isTextVisible {
                    VStack(spacing: -2) {
                        if menuBarPreferencesModel.showArtist {
                            Text(model.artist)
                                .font(.system(size: 10, weight: .medium))
                        }
                        if menuBarPreferencesModel.showTitle {
                            Text(model.title)
                                .font(.system(size: 9))
                        }
                    }
                }
            } else {
                Text(
                    model.buildText(
                        menuBarPreferencesModel: menuBarPreferencesModel,
                        font: NSFont.systemFont(ofSize: 13)
                    )
                )
                .font(.system(size: 13))
            }
        }
    }
}

struct StatusItemDisplayHelper {
    static func shouldShowAppIcon(
        preferences: MenuBarPreferencesModel,
        model: StatusItemModel
    ) -> Bool {
        if preferences.showAppIcon {
            return true
        }

        let noArtist = !preferences.showArtist || model.artist.isEmpty
        let noTitle = !preferences.showTitle || model.title.isEmpty
        let noPlaying = !preferences.showIsPlayingIcon || !model.isPlaying

        let nothingToShow = noArtist && noTitle && noPlaying
        return nothingToShow
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
        preferences: PlayerPreferencesModel()
    )
    return StatusItemView(
        model: model,
        menuBarPreferencesModel: preferences,
        playbackModel: playbackModel
    )
}
