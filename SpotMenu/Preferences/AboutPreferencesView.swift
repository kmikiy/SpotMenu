import SwiftUI

struct AboutPreferencesView: View {
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // App Icon and Name
                VStack(spacing: 12) {
                    Image(nsImage: NSApp.applicationIconImage)
                        .resizable()
                        .frame(width: 128, height: 128)
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)

                    Text("SpotMenu")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Version \(appVersion) (\(buildNumber))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)

                Divider()
                    .padding(.horizontal, 40)

                // Donation Section
                VStack(spacing: 12) {
                    Text("Support Development")
                        .font(.headline)

                    Text("SpotMenu is free and open source.\nIf you enjoy it, consider fueling my coffee addiction\nso I can mass produce more questionable side projects.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)

                    Button(action: {
                        if let url = URL(string: "https://paypal.me/kmikiy") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.white)
                            Text("Donate via PayPal")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                }
                .padding(.vertical, 8)

                Divider()
                    .padding(.horizontal, 40)

                // Description
                VStack(spacing: 8) {
                    Text("Spotify & Apple Music in your menu bar")
                        .font(.headline)

                    Text("Built with SwiftUI for macOS")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Divider()
                    .padding(.horizontal, 40)

                // Links
                VStack(spacing: 12) {
                    Button(action: {
                        if let url = URL(string: "https://github.com/kmikiy/SpotMenu") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "link")
                            Text("View on GitHub")
                        }
                    }
                    .buttonStyle(.link)

                    Button(action: {
                        if let url = URL(string: "https://kmikiy.github.io/SpotMenu") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "globe")
                            Text("Website")
                        }
                    }
                    .buttonStyle(.link)
                }

                Spacer()

                // Copyright
                Text("Made with love by @kmikiy")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.bottom, 20)
            }
            .frame(maxWidth: 400)
            .padding(20)
        }
    }
}

#Preview {
    AboutPreferencesView()
}
