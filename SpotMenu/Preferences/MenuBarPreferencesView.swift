import SwiftUI

struct MenuBarPreferencesView: View {
    @ObservedObject var model: MenuBarPreferencesModel
    @ObservedObject var playbackModel: PlaybackModel
    @ObservedObject var musicPlayerPreferencesModel: MusicPlayerPreferencesModel

    @StateObject private var previewModel: StatusItemModel = {
        let model = StatusItemModel()
        model.artist = "Lorem Ipsum"
        model.title = "Ut Sit Amet Justo Efficitur, Imperdiet Elit Sit Amet"
        model.isPlaying = true
        model.isLiked = true
        return model
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Menu Bar Settings")
                .font(.title2)
                .bold()
                .padding(.bottom, 8)

            VStack(spacing: 10) {
                settingsRow("Display Artist", binding: $model.showArtist)
                settingsRow("Display Song Title", binding: $model.showTitle)
                settingsRow(
                    "Show Playing Icon",
                    binding: $model.showIsPlayingIcon
                )
                if playbackModel.isLikingImplemented
                    && musicPlayerPreferencesModel.likingEnabled {
                    settingsRow("Show Liked Icon", binding: $model.showIsLikedIcon)
                }
                
                settingsRow("Display App Icon", binding: $model.showAppIcon)
                settingsRow("Compact View", binding: $model.compactView)

                HStack {
                    Text("Max Width")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Slider(
                        value: $model.maxStatusItemWidth,
                        in: 80...300,
                        step: 1
                    )
                    .frame(width: 200)
                    Text("\(Int(model.maxStatusItemWidth)) pt")
                        .frame(width: 50)
                }

                if shouldShowAlwaysFallbackWarning {
                    Text(
                        "Note: All display options are turned off. The app icon will be shown as a fallback to prevent an empty status item."
                    )
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
                } else if shouldShowPlayingOnlyFallbackWarning {
                    Text(
                        "Note: If only 'Show Playing Icon' is enabled but nothing is playing, the app icon will be shown as a fallback."
                    )
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
                } else if shouldShowLikedOnlyFallbackWarning {
                    Text(
                        "Note: If only 'Show Liked Icon' is enabled but the liked status is unavailable, the app icon will be shown as a fallback."
                    )
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    Text("Status Item Preview")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {
                        StatusItemView(
                            model: previewModel,
                            menuBarPreferencesModel: model,
                            musicPlayerPreferencesModel:
                                musicPlayerPreferencesModel,
                            playbackModel: playbackModel
                        )
                        .frame(width: model.maxStatusItemWidth, height: 22)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(
                                    style: StrokeStyle(lineWidth: 1, dash: [4])
                                )
                                .foregroundColor(.gray.opacity(0.4))
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                    Text(
                        "Maximum width shown. Actual width may be smaller depending on content."
                    )
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .frame(width: 300)
            }

            Spacer()
        }
        .padding(20)
        .frame(width: 400, height: 460)
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

    private var shouldShowAlwaysFallbackWarning: Bool {
        let noArtist = !model.showArtist
        let noTitle = !model.showTitle
        let noIsPlaying = !model.showIsPlayingIcon
        let noIsLiked =
            !model.showIsLikedIcon || !playbackModel.isLikingImplemented
            || !musicPlayerPreferencesModel.likingEnabled
        let noDisplayAppIcon = !model.showAppIcon

        return noArtist && noTitle && noIsPlaying && noIsLiked
            && noDisplayAppIcon
    }

    private var shouldShowPlayingOnlyFallbackWarning: Bool {
        let noArtist = !model.showArtist
        let noTitle = !model.showTitle
        let yesIsPlaying = model.showIsPlayingIcon
        let noIsLiked =
            !model.showIsLikedIcon || !playbackModel.isLikingImplemented
            || !musicPlayerPreferencesModel.likingEnabled
        let noDisplayAppIcon = !model.showAppIcon

        return noArtist && noTitle && yesIsPlaying && noIsLiked
            && noDisplayAppIcon
    }

    private var shouldShowLikedOnlyFallbackWarning: Bool {
        let noArtist = !model.showArtist
        let noTitle = !model.showTitle
        let noIsPlaying = !model.showIsPlayingIcon
        let yesIsLiked =
            model.showIsLikedIcon && playbackModel.isLikingImplemented
            && musicPlayerPreferencesModel.likingEnabled
        let noDisplayAppIcon = !model.showAppIcon

        return noArtist && noTitle && noIsPlaying && yesIsLiked
            && noDisplayAppIcon
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
