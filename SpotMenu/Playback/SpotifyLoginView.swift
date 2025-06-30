import SwiftUI

struct SpotifyLoginView: View {
    @ObservedObject var authManager = SpotifyAuthManager.shared

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 40) {
                VStack(spacing: 12) {
                    if let appIcon = NSApp.applicationIconImage {
                        Image(nsImage: appIcon)
                            .resizable()
                            .frame(width: 88, height: 88)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 4)

                    }

                    Text("SpotMenu")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)

                    Text("Log in to connect your Spotify account")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                }

                if authManager.isAuthenticated {
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .foregroundColor(.spotifyGreen)
                                .font(.title3)
                                .scaledToFit()
                                .frame(width: 20, height: 20)

                            Text("You're now logged in to Spotify.")
                                .foregroundColor(.white)
                                .font(.headline)
                        }

                        Text("You can close this window.")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                } else {
                    Button(action: {
                        authManager.startAuthentication()
                    }) {
                        HStack(alignment: .center, spacing: 12) {
                            Image(systemName: "arrow.right.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.black)

                            Text("Continue with Spotify")
                                .foregroundColor(.black)
                                .font(.headline)
                        }
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 22,
                            alignment: .center
                        )
                        .padding()
                        .background(Color.spotifyGreen)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 260)

                }

                Spacer()
            }
            .padding(.top, 80)
        }
        .frame(width: 360, height: 380)
    }
}

#Preview {
    SpotifyLoginView()
}

extension Color {
    static let spotifyGreen = Color(
        red: 29 / 255,
        green: 185 / 255,
        blue: 84 / 255
    )
}
