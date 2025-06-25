import SwiftUI

struct NowPlayingHUDView: View {
    @ObservedObject var model: PlaybackModel
    @Binding var isVisible: Bool

    @State private var animateText: Bool = false
    @State private var showImage: Bool = false

    var body: some View {
        ZStack {
            Color.clear
                .background(.ultraThinMaterial)
                .ignoresSafeArea()

            HStack(spacing: 40) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.gray.opacity(0.00))
                        .frame(width: 600, height: 600)

                    if let image = model.image {
                        image
                            .resizable()
                            .frame(width: 600, height: 600)
                            .aspectRatio(contentMode: .fill)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(radius: 20)
                            .opacity(showImage ? 1 : 0)
                            .animation(
                                .easeInOut(duration: 0.3),
                                value: showImage
                            )
                            .onAppear {
                                showImage = false
                                DispatchQueue.main.asyncAfter(
                                    deadline: .now() + 0.05
                                ) {
                                    showImage = true
                                }
                            }
                    } else if let url = model.imageURL {
                        AsyncImage(url: url) { phase in
                            if case .success(let image) = phase {
                                image
                                    .resizable()
                                    .frame(width: 600, height: 600)
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 24)
                                    )
                                    .shadow(radius: 20)
                                    .opacity(showImage ? 1 : 0)
                                    .animation(
                                        .easeInOut(duration: 0.3),
                                        value: showImage
                                    )
                                    .onAppear {
                                        showImage = false
                                        DispatchQueue.main.asyncAfter(
                                            deadline: .now() + 0.05
                                        ) {
                                            showImage = true
                                        }
                                    }
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
                .opacity(animateText ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: animateText)
            }
            .padding(60)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                isVisible = false
            }
        }
        .onChange(of: isVisible) { _, visible in
            if visible {
                animateText = false
                showImage = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animateText = true
                }
            } else {
                animateText = false
                showImage = false
            }
        }
        .onAppear {
            if isVisible {
                animateText = false
                showImage = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animateText = true
                }
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
