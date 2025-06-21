import SwiftUI

struct StatusItemView: View {
    @ObservedObject var model: StatusItemModel
    @ObservedObject var preferencesModel: VisualPreferencesModel

    var body: some View {
        Group {
            if model.showAppIconOnly || preferencesModel.showAppIconOnly {
                Image("SpotifyIcon")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .clipShape(Circle())
            } else {
                HStack(spacing: 4) {
                    Image("SpotifyIcon")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 16, height: 16)
                        .clipShape(Circle())

                    if preferencesModel.showIsPlayingIcon && model.isPlaying {
                        Text("♫").font(.system(size: 13))
                    }

                    if !model.isTextEmpty && preferencesModel.isTextVisible {
                        let sharedWidth = calculateMaxTextWidth(
                            topText: preferencesModel.showArtist ? model.topText : nil,
                            topFont: .systemFont(ofSize: 10, weight: .medium),
                            bottomText: preferencesModel.showSongTitle ? model.bottomText : nil,
                            bottomFont: .systemFont(ofSize: 9)
                        )

                        VStack(spacing: -2) {
                            if preferencesModel.showArtist {
                                AutoMarqueeTextView(
                                    text: model.topText,
                                    font: .systemFont(ofSize: 10, weight: .medium),
                                    speed: 20
                                )
                                .frame(width: sharedWidth, height: 12)
                            }

                            if preferencesModel.showSongTitle {
                                AutoMarqueeTextView(
                                    text: model.bottomText,
                                    font: .systemFont(ofSize: 9),
                                    speed: 20
                                )
                                .frame(width: sharedWidth, height: 11)
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

    private func calculateMaxTextWidth(
        topText: String?,
        topFont: NSFont,
        bottomText: String?,
        bottomFont: NSFont
    ) -> CGFloat {
        let iconWidth: CGFloat = 16
        let spacing: CGFloat = 4
        let musicIconWidth: CGFloat = (preferencesModel.showIsPlayingIcon && model.isPlaying) ? 16 : 0
        let totalMaxWidth = preferencesModel.maxStatusItemWidth
        let availableWidth = totalMaxWidth - iconWidth - spacing - musicIconWidth

        let topWidth = topText.map {
            NSString(string: $0).size(withAttributes: [.font: topFont]).width
        } ?? 0

        let bottomWidth = bottomText.map {
            NSString(string: $0).size(withAttributes: [.font: bottomFont]).width
        } ?? 0

        return min(max(topWidth, bottomWidth), availableWidth)
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
    return StatusItemView(
        model: model,
        preferencesModel: preferences
    )
}
