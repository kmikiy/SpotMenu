import SwiftUI

struct PlaybackView: View {
    @ObservedObject var model: PlaybackModel
    @State private var isHovering = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .frame(width: 300, height: 300)

            if let url = model.imageURL {
                AsyncImage(url: url) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300, height: 300)
                            .clipped()
                            .blur(radius: isHovering ? 8 : 0)
                            .overlay(
                                isHovering
                                    ? Color.accentColor.opacity(0.3) : nil
                            )
                    }
                }
                .clipShape(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
            } else if let fallbackImage = model.image {
                fallbackImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 300)
                    .clipped()
                    .blur(radius: isHovering ? 8 : 0)
                    .overlay(
                        isHovering
                            ? Color.accentColor.opacity(0.3) : nil
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
            } else {
                ZStack {
                    Color.clear

                    Image(systemName: "music.note")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white.opacity(0.2))
                        .frame(width: 100, height: 100)
                }
                .frame(width: 300, height: 300)
                .blur(radius: isHovering ? 8 : 0)
                .overlay(
                    isHovering ? Color.accentColor.opacity(0.3) : nil
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
            }

            if isHovering {
                VStack(spacing: 0) {
                    HStack {
                        Button(action: model.openMusicApp) {
                            Image(model.playerIconName)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                                .padding(0)
                                .contentShape(Rectangle())
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
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                                .padding(0)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding([.top, .leading, .trailing], 16)
                    .padding([.bottom], 24)

                    VStack(spacing: 12) {
                        Text(model.artist)
                            .font(.title3)
                            .foregroundColor(.white)
                            .lineLimit(2)

                        HStack(spacing: 10) {
                            tappableIconButton(
                                imageName: "backward.fill",
                                imageSize: 30
                            ) {
                                model.skipBack()
                            }

                            tappableIconButton(
                                imageName: model.isPlaying
                                    ? "pause.fill" : "play.fill",
                                imageSize: 40
                            ) {
                                model.togglePlayPause()
                            }

                            tappableIconButton(
                                imageName: "forward.fill",
                                imageSize: 30
                            ) {
                                model.skipForward()
                            }
                        }
                        .foregroundColor(.white)

                        Text(model.title)
                            .font(.title3)
                            .foregroundColor(.white)
                            .lineLimit(2)
                    }

                    Spacer(minLength: 0)

                    HStack {
                        Text(formatTime(model.currentTime))
                            .font(.body.monospacedDigit())
                            .foregroundColor(.white)
                            .frame(width: 30, alignment: .leading)

                        Slider(
                            value: Binding(
                                get: { model.currentTime },
                                set: { model.updatePlaybackPosition(to: $0) }
                            ),
                            in: 0...model.totalTime
                        )
                        .accentColor(.accentColor)
                        .frame(width: 200)
                        .preferredColorScheme(.light)

                        Text(formatTime(model.totalTime))
                            .font(.body.monospacedDigit())
                            .foregroundColor(.white)
                            .frame(width: 30, alignment: .trailing)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
                .padding(.horizontal)
                .transition(.opacity)

            }
        }
        .frame(width: 300, height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

#Preview {
    let model = PlaybackModel(preferences: PlayerPreferencesModel())
    model.imageURL = URL(
        string:
            "https://i.scdn.co/image/ab67616d0000b27377054612c5275c1515b18a50"
    )
    model.artist = "The Weeknd"
    return PlaybackView(model: model)
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
