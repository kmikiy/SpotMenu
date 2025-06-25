import SwiftUI

struct NowPlayingHUDView: View {
    @ObservedObject var model: PlaybackModel
    @Binding var isVisible: Bool

    var body: some View {
        ZStack {
            // Background blur + fade
            Color.clear
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .transition(.opacity)

            // Main content
            HStack(spacing: 40) {
                ZStack {
                    // Placeholder to maintain layout
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 600, height: 600)
                        .overlay(
                            Image(systemName: "music.note")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray.opacity(0.6))
                        )

                    // Loaded image (Apple Music)
                    if let image = model.image {
                        image
                            .resizable()
                            .frame(width: 600, height: 600)
                            .aspectRatio(contentMode: .fill)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(radius: 20)
                    }

                    // Loaded image (Spotify or Async)
                    else if let url = model.imageURL {
                        AsyncImage(url: url) { phase in
                            if case .success(let image) = phase {
                                image
                                    .resizable()
                                    .frame(width: 600, height: 600)
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                                    .shadow(radius: 20)
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(model.title)
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(3)
                        .minimumScaleFactor(0.7)

                    Text(model.artist)
                        .font(.system(size: 28, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: 600, alignment: .leading)
            }
            .padding(60)
            .transition(.scale.combined(with: .opacity))
        }
        .contentShape(Rectangle())  // For tap detection
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                isVisible = false
            }
        }
    }
}

#Preview {
    let model = PlaybackModel(preferences: PlayerPreferencesModel())
    model.imageURL = URL(
        string:
            "https://i.scdn.co/image/ab67616d0000b27377054612c5275c1515b18a50"
    )
    model.artist = "The Weeknd"
    model.isPlaying = true
    model.title = "Blinding Lights"

    return NowPlayingHUDView(model: model, isVisible: .constant(true))
}
