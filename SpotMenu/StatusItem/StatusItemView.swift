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

                    if preferencesModel.showIsPlayingIcon
                        && model.isPlaying
                    {
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
