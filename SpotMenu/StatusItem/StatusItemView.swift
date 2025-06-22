import SwiftUI

struct StatusItemView: View {
    @ObservedObject var model: StatusItemModel
    @ObservedObject var preferencesModel: VisualPreferencesModel
    @ObservedObject var playbackModel: PlaybackModel

    var body: some View {
        let showIcon = StatusItemDisplayHelper.shouldShowAppIcon(
            preferences: preferencesModel,
            model: model
        )

        Group {
            if showIcon && !preferencesModel.isTextVisible && !model.isPlaying {
                Image(playbackModel.playerIconName)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .clipShape(Circle())
            } else {
                HStack(spacing: 4) {
                    if showIcon {
                        Image(playbackModel.playerIconName)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 16, height: 16)
                            .clipShape(Circle())
                    }

                    if preferencesModel.showIsPlayingIcon && model.isPlaying {
                        Text("♫").font(.system(size: 13))
                    }

                    if !model.isTextEmpty && preferencesModel.isTextVisible {
                        VStack(spacing: -2) {
                            if preferencesModel.showArtist {
                                Text(model.topText)
                                    .font(.system(size: 10, weight: .medium))
                            }
                            if preferencesModel.showSongTitle {
                                Text(model.bottomText)
                                    .font(.system(size: 9))
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 0)
        .padding(.vertical, 2)
        .background(Color.clear)
        .frame(maxWidth: preferencesModel.maxStatusItemWidth)
        .lineLimit(1)
        .truncationMode(.tail)
    }
}

struct StatusItemDisplayHelper {
    static func shouldShowAppIcon(
        preferences: VisualPreferencesModel,
        model: StatusItemModel
    ) -> Bool {
        if preferences.showAppIcon {
            return true
        }

        let noArtist = !preferences.showArtist || model.topText.isEmpty
        let noTitle = !preferences.showSongTitle || model.bottomText.isEmpty
        let noPlaying = !preferences.showIsPlayingIcon || !model.isPlaying

        let nothingToShow = noArtist && noTitle && noPlaying
        return nothingToShow
    }
}

#Preview {
    let model = StatusItemModel()
    model.topText = "test"  // artist
    model.bottomText =
        "very long text that should be truncated very very long text"  // title
    model.isPlaying = true  // is playing

    let preferences = VisualPreferencesModel()
    preferences.showArtist = true
    preferences.showSongTitle = true
    preferences.showIsPlayingIcon = true
    
    let playbackModel = PlaybackModel()
    return StatusItemView(
        model: model,
        preferencesModel: preferences,
        playbackModel: playbackModel
    )
}
