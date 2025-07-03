import AppKit
import SwiftUI

struct PlaybackView: View {
    @ObservedObject var model: PlaybackModel
    @ObservedObject var preferences: PlaybackAppearancePreferencesModel
    @ObservedObject var musicPlayerPreferencesModel: MusicPlayerPreferencesModel
    @State private var isHovering = false
    @Environment(\.colorScheme) private var systemColorScheme

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .frame(width: 300, height: 300)

            content
                .clipShape(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
        }
        .frame(width: 300, height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        let blurRadius = isHovering ? preferences.blurIntensity * 10 : 0
        let overlayColor =
            isHovering
            ? adaptiveHoverTintColor.opacity(preferences.hoverTintOpacity)
            : nil

        if let url = model.imageURL {
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 300, height: 300)
                        .clipped()
                        .blur(radius: blurRadius)
                        .overlay(overlayColor)
                }
            }
        } else if let fallbackImage = model.image {
            fallbackImage
                .resizable()
                .scaledToFill()
                .frame(width: 300, height: 300)
                .clipped()
                .blur(radius: blurRadius)
                .overlay(overlayColor)
        } else {
            ZStack {
                Color.clear
                Image(systemName: "music.note")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(
                        preferences.foregroundColor.color.opacity(0.2)
                    )
                    .frame(width: 100, height: 100)
            }
            .frame(width: 300, height: 300)
            .blur(radius: blurRadius)
            .overlay(overlayColor)
        }

        if isHovering {
            controlsOverlay
        }
    }

    private var controlsOverlay: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: model.openMusicApp) {
                    Image(model.playerIconName)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(preferences.foregroundColor.color)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: {
                    NSApp.sendAction(
                        #selector(AppDelegate.preferencesAction),
                        to: nil,
                        from: nil
                    )
                }) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(preferences.foregroundColor.color)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
            }
            .padding([.top, .leading, .trailing], 16)
            .padding(.bottom, 24)

            VStack(spacing: 12) {
                Text(model.artist)
                    .font(.title3)
                    .foregroundColor(preferences.foregroundColor.color)
                    .lineLimit(2)
                    .padding(.horizontal)

                HStack(spacing: 10) {
                    tappableIconButton(
                        imageName: "backward.fill",
                        imageSize: 30
                    ) {
                        model.skipBack()
                    }

                    tappableIconButton(
                        imageName: model.isPlaying ? "pause.fill" : "play.fill",
                        imageSize: 40
                    ) {
                        model.togglePlayPause()
                    }

                    tappableIconButton(imageName: "forward.fill", imageSize: 30)
                    {
                        model.skipForward()
                    }
                }
                .foregroundColor(preferences.foregroundColor.color)

                Text(model.title)
                    .font(.title3)
                    .foregroundColor(preferences.foregroundColor.color)
                    .lineLimit(2)
                    .padding(.horizontal)
            }

            Spacer(minLength: 0)

            HStack(alignment: .center) {

                Text(model.formatTime(model.currentTime))
                    .font(.body.monospacedDigit())
                    .foregroundColor(preferences.foregroundColor.color)
                    .frame(alignment: .leading)
                    .fixedSize(horizontal: true, vertical: false)

                CustomSlider(
                    value: Binding(
                        get: { model.currentTime },
                        set: { model.updatePlaybackPosition(to: $0) }
                    ),
                    range: 0...model.totalTime,
                    foregroundColor: preferences.foregroundColor.color,
                    trackColor: preferences.foregroundColor.color
                )
                .frame(maxWidth: .infinity)

                Text(model.formatTime(model.totalTime))
                    .font(.body.monospacedDigit())
                    .foregroundColor(preferences.foregroundColor.color)
                    .frame(alignment: .trailing)
                    .fixedSize(horizontal: true, vertical: false)

                if model.isLikingImplemented
                    && musicPlayerPreferencesModel.likingEnabled
                {
                    Group {
                        if let isLiked = model.isLiked {
                            Button(action: {
                                model.toggleLiked()
                            }) {
                                Image(
                                    systemName: isLiked ? "heart.fill" : "heart"
                                )
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(
                                    preferences.foregroundColor.color
                                )
                                .frame(width: 20, height: 20)
                            }
                            .buttonStyle(.plain)
                            .help("Toggle like status")
                        } else {
                            Button(action: {
                                model.toggleLiked()  // triggers login
                            }) {
                                Image(systemName: "heart")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(
                                        preferences.foregroundColor.color
                                            .opacity(0.3)
                                    )
                                    .frame(width: 20, height: 20)
                            }
                            .buttonStyle(.plain)
                            .help("Login to enable liking tracks")
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)

        }
        .padding(.horizontal)
        .transition(.opacity)
    }

    private var adaptiveHoverTintColor: Color {
        return Color(preferences.hoverTintColor)
    }
}

#Preview {
    let model = PlaybackModel(preferences: MusicPlayerPreferencesModel())
    model.imageURL = URL(
        string:
            "https://i.scdn.co/image/ab67616d0000b27377054612c5275c1515b18a50"
    )
    model.artist = "The Weeknd"
    return PlaybackView(
        model: model,
        preferences: PlaybackAppearancePreferencesModel(),
        musicPlayerPreferencesModel: MusicPlayerPreferencesModel()
    )
}

@ViewBuilder
func tappableIconButton(
    imageName: String,
    imageSize: CGFloat,
    action: @escaping () -> Void
) -> some View {
    Button(action: action) {
        Image(systemName: imageName)
            .resizable()
            .scaledToFit()
            .frame(width: imageSize, height: imageSize)
            .padding(30)
            .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
}
