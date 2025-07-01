import SwiftUI

struct StatusItemView: View {
    @ObservedObject var model: StatusItemModel
    @ObservedObject var menuBarPreferencesModel: MenuBarPreferencesModel
    @ObservedObject var playbackModel: PlaybackModel

    @State private var animationState: AnimationType? = nil

    enum AnimationType {
        case heart
        case brokenHeart
    }

    var body: some View {
        ZStack {
            content
                .opacity(animationState == nil ? 1 : 0)

            if let animation = animationState {
                Image(systemName: animation == .heart ? "heart.fill" : "heart.slash.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 10)
                    .foregroundColor(animation == .heart ? .red : .gray)
                    .scaleEffect(1.4)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(maxWidth: menuBarPreferencesModel.maxStatusItemWidth)
        .padding(.horizontal, 0)
        .padding(.vertical, 2)
        .background(Color.clear)
        .lineLimit(1)
        .truncationMode(.tail)
        .onReceive(playbackModel.$likeChangedTo.removeDuplicates()) { newValue in
            guard let newValue else { return }
            triggerAnimation(newValue ? .heart : .brokenHeart)
        }
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

    private func triggerAnimation(_ type: AnimationType) {
        withAnimation(.easeOut(duration: 0.2)) {
            animationState = type
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.25)) {
                animationState = nil
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
