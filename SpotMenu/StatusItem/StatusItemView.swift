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

                    if preferencesModel.compactView {
                        if !model.isTextEmpty && preferencesModel.isTextVisible
                        {
                            let compactWidth = calculateMaxTextWidth(
                                topText: preferencesModel.showArtist
                                    ? model.artist : nil,
                                topFont: .systemFont(
                                    ofSize: 10,
                                    weight: .medium
                                ),
                                bottomText: preferencesModel.showTitle
                                    ? model.title : nil,
                                bottomFont: .systemFont(ofSize: 9)
                            )

                            VStack(spacing: -2) {
                                if preferencesModel.showArtist {
                                    if preferencesModel.enableScrollingText {
                                        AutoMarqueeTextView(
                                            text: model.artist,
                                            font: .systemFont(
                                                ofSize: 10,
                                                weight: .medium
                                            ),
                                            speed: 20
                                        )
                                        .frame(width: compactWidth, height: 12)
                                    } else {
                                        Text(model.artist)
                                            .font(
                                                .system(
                                                    size: 10,
                                                    weight: .medium
                                                )
                                            )
                                            .frame(
                                                width: compactWidth,
                                                height: 12
                                            )
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                }

                                if preferencesModel.showTitle {
                                    if preferencesModel.enableScrollingText {
                                        AutoMarqueeTextView(
                                            text: model.title,
                                            font: .systemFont(ofSize: 9),
                                            speed: 20
                                        )
                                        .frame(width: compactWidth, height: 11)
                                    } else {
                                        Text(model.title)
                                            .font(.system(size: 9))
                                            .frame(
                                                width: compactWidth,
                                                height: 11
                                            )
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                }
                            }
                        }
                    } else {
                        let (text, _) = model.buildText(
                            visualPreferencesModel: preferencesModel,
                            font: NSFont.systemFont(ofSize: 13)
                        )
                        let normalWidth = calculateMaxTextWidth(
                            topText: text,
                            topFont: .systemFont(ofSize: 13, weight: .medium),
                            bottomText: nil,
                            bottomFont: .systemFont(ofSize: 9)
                        )

                        if preferencesModel.enableScrollingText {
                            AutoMarqueeTextView(
                                text: text,
                                font: .systemFont(ofSize: 13),
                                speed: 20
                            )
                            .frame(width: normalWidth, height: 16)
                        } else {
                            Text(text)
                                .font(.system(size: 13))
                                .frame(width: normalWidth, height: 18)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 0)
        .padding(.vertical, 2)
        .background(Color.clear)
        .frame(maxWidth: preferencesModel.maxStatusItemWidth + 2)
        .lineLimit(1)
        .truncationMode(.tail)
    }

    private func calculateMaxTextWidth(
        topText: String?,
        topFont: NSFont,
        bottomText: String?,
        bottomFont: NSFont
    ) -> CGFloat {
        let iconWidth: CGFloat = 16
        let spacing: CGFloat = 4
        let musicIconWidth: CGFloat =
            (preferencesModel.showIsPlayingIcon && model.isPlaying) ? 16 : 0
        let totalMaxWidth = preferencesModel.maxStatusItemWidth
        let availableWidth =
            totalMaxWidth - iconWidth - spacing - musicIconWidth

        let topWidth =
            topText.map {
                NSString(string: $0).size(withAttributes: [.font: topFont])
                    .width
            } ?? 0

        let bottomWidth =
            bottomText.map {
                NSString(string: $0).size(withAttributes: [.font: bottomFont])
                    .width
            } ?? 0

        let rawWidth = min(max(topWidth, bottomWidth), availableWidth)

        // Round to the nearest whole number
        return ceil(rawWidth)
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

    let preferences = VisualPreferencesModel()
    preferences.showArtist = true
    preferences.showTitle = true
    preferences.showIsPlayingIcon = true
    preferences.compactView = false

    let playbackModel = PlaybackModel(
        preferences: PlayerPreferencesModel()
    )
    return StatusItemView(
        model: model,
        preferencesModel: preferences,
        playbackModel: playbackModel
    )
}
