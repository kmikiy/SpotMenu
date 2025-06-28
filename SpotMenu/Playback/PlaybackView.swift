import AppKit
import SwiftUI

struct PlaybackView: View {
    @ObservedObject var model: PlaybackModel
    @ObservedObject var preferences: PlayerPreferencesModel
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
            isHovering ? adaptiveHoverTintColor.opacity(0.3) : nil

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

            HStack {
                Text(formatTime(model.currentTime))
                    .font(.body.monospacedDigit())
                    .foregroundColor(preferences.foregroundColor.color)
                    .frame(width: 30, alignment: .leading)

                CustomSlider(
                    value: Binding(
                        get: { model.currentTime },
                        set: { model.updatePlaybackPosition(to: $0) }
                    ),
                    range: 0...model.totalTime,
                    foregroundColor: preferences.foregroundColor.color,
                    trackColor: preferences.foregroundColor.color
                )
                .frame(width: 200)

                Text(formatTime(model.totalTime))
                    .font(.body.monospacedDigit())
                    .foregroundColor(preferences.foregroundColor.color)
                    .frame(width: 30, alignment: .trailing)
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
    return PlaybackView(model: model, preferences: PlayerPreferencesModel())
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

struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let foregroundColor: Color
    let trackColor: Color

    private let height: CGFloat = 6
    private let thumbSize: CGFloat = 20

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: height)

                // Progress fill
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(trackColor)
                    .frame(
                        width: progressWidth(in: geometry.size.width),
                        height: height
                    )

                // Thumb
                Circle()
                    .fill(foregroundColor)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(
                        x: thumbOffset(in: geometry.size.width) - thumbSize / 2
                    )
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    .contentShape(Rectangle().inset(by: -10))
                    .animation(.easeInOut(duration: 0.15), value: value)
            }
            .frame(height: max(height, thumbSize))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        let clampedX = min(
                            max(0, drag.location.x),
                            geometry.size.width
                        )
                        let relative = clampedX / geometry.size.width
                        let newValue =
                            range.lowerBound
                            + (range.upperBound - range.lowerBound)
                            * Double(relative)
                        withAnimation(.easeInOut(duration: 0.15)) {
                            value = newValue
                        }
                    }
            )
        }
        .frame(height: thumbSize)
    }

    private func progressWidth(in totalWidth: CGFloat) -> CGFloat {
        let clampedValue = max(range.lowerBound, min(range.upperBound, value))
        let percent =
            (clampedValue - range.lowerBound)
            / (range.upperBound - range.lowerBound)
        return CGFloat(percent) * totalWidth
    }

    private func thumbOffset(in totalWidth: CGFloat) -> CGFloat {
        progressWidth(in: totalWidth)
    }
}
