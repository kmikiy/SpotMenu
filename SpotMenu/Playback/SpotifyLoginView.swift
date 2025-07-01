import SwiftUI

struct SpotifyLoginView: View {
    @ObservedObject var authManager = SpotifyAuthManager.shared
    @ObservedObject var preferences: MusicPlayerPreferencesModel
    @State private var currentStep: Int = 0
    @State private var instructionStep: Int = 0

    private let instructions: [String] = [
        "1. Visit developer.spotify.com/dashboard",
        "2. Log in and click “Create an App”",
        "3. Fill out name & description (e.g. SpotMenu)",
        "4. Set this redirect URI:\n com.github.kmikiy.spotmenu://callback",
        "5. Save and copy your Client ID above",
    ]

    private var hasValidClientID: Bool {
        !(preferences.spotifyClientID ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

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

                    Text(
                        currentStep == 0
                            ? "Set up your Spotify Client ID"
                            : "Log in to connect your Spotify account"
                    )
                    .font(.title3.bold())
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)
                }

                if currentStep == 0 {
                    stepClientIDEntry
                } else {
                    stepLogin
                }

                Spacer()
            }
            .padding(.top, 40)

            VStack {
                Spacer()
                Divider()
                HStack {
                    if currentStep == 1 || instructionStep > 0 {
                        Button("Back") {
                            if currentStep == 1 {
                                currentStep = 0
                                instructionStep = instructions.count - 1
                            } else {
                                instructionStep -= 1
                            }
                        }
                        .foregroundColor(.gray)
                    }

                    Spacer()

                    if currentStep == 0 {
                        Button("Continue") {
                            if instructionStep < instructions.count - 1 {
                                instructionStep += 1
                            } else {
                                currentStep = 1
                            }
                        }
                        .disabled(
                            instructionStep == instructions.count - 1
                                && (preferences.spotifyClientID ?? "")
                                    .trimmingCharacters(
                                        in: .whitespacesAndNewlines
                                    )
                                    .isEmpty
                        )
                        .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
            }
        }
        .frame(width: 500, height: 580)
        .onAppear {
            if hasValidClientID {
                currentStep = 1
            }
        }
    }

    private var stepClientIDEntry: some View {
        VStack(spacing: 16) {
            TextField(
                "Enter Spotify Client ID",
                text: Binding(
                    get: { preferences.spotifyClientID ?? "" },
                    set: { newValue in
                        let trimmed = newValue.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )
                        preferences.spotifyClientID =
                            trimmed.isEmpty ? nil : trimmed
                    }
                )
            )
            .textFieldStyle(.roundedBorder)
            .font(.system(size: 13))
            .frame(width: 300)

            VStack(alignment: .leading, spacing: 6) {
                Text("Don't have one? Follow these steps:")
                    .foregroundColor(.white.opacity(0.85))
                    .font(.system(size: 16, weight: .semibold))
                    .multilineTextAlignment(.leading)
                    .padding([.bottom, .top])

                ForEach(Array(instructions.enumerated()), id: \.offset) {
                    index,
                    step in
                    switch index {
                    case 0:
                        HStack(alignment: .top, spacing: 0) {
                            Text("1. Visit ")
                                .font(.system(size: 15))
                                .foregroundColor(
                                    index == instructionStep ? .white : .gray
                                )

                            Button(action: {
                                if let url = URL(
                                    string:
                                        "https://developer.spotify.com/dashboard"
                                ) {
                                    NSWorkspace.shared.open(url)
                                }
                            }) {
                                Text("developer.spotify.com/dashboard")
                                    .underline()
                                    .font(.system(size: 15))
                                    .foregroundColor(
                                        index == instructionStep
                                            ? .white : .gray
                                    )
                            }
                            .buttonStyle(.plain)
                            .onHover { _ in NSCursor.pointingHand.set() }
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, index == instructionStep ? 12 : 0)
                        .background(
                            index == instructionStep
                                ? Color.white.opacity(0.08).cornerRadius(6)
                                : nil
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)

                    case 3:
                        VStack(alignment: .leading, spacing: 4) {
                            Text("4. Set this redirect URI:")
                                .font(.system(size: 15))
                                .foregroundColor(
                                    index == instructionStep ? .white : .gray
                                )

                            HStack(spacing: 8) {
                                Text("com.github.kmikiy.spotmenu://callback")
                                    .font(
                                        .system(size: 13, design: .monospaced)
                                    )
                                    .foregroundColor(.white)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 6)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(4)

                                Button(action: {
                                    let pasteboard = NSPasteboard.general
                                    pasteboard.clearContents()
                                    pasteboard.setString(
                                        "com.github.kmikiy.spotmenu://callback",
                                        forType: .string
                                    )
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 14, height: 14)
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(4)
                                }
                                .buttonStyle(.plain)
                                .onHover { _ in NSCursor.pointingHand.set() }
                            }
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, index == instructionStep ? 12 : 0)
                        .background(
                            index == instructionStep
                                ? Color.white.opacity(0.08).cornerRadius(6)
                                : nil
                        )

                    default:
                        Text(step)
                            .font(.system(size: 15))
                            .foregroundColor(
                                index == instructionStep ? .white : .gray
                            )
                            .padding(.vertical, 4)
                            .padding(
                                .horizontal,
                                index == instructionStep ? 12 : 0
                            )
                            .background(
                                index == instructionStep
                                    ? Color.white.opacity(0.08).cornerRadius(6)
                                    : nil
                            )
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .frame(width: 400, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }

    private var stepLogin: some View {
        VStack(spacing: 16) {
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
                Spacer()
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
                    .frame(maxWidth: .infinity, minHeight: 22)
                    .padding()
                    .background(Color.spotifyGreen)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .frame(width: 260)
                Spacer()
            }
        }
    }
}

extension Color {
    static let spotifyGreen = Color(
        red: 29 / 255,
        green: 185 / 255,
        blue: 84 / 255
    )
}

#Preview {
    SpotifyLoginView(preferences: MusicPlayerPreferencesModel())
}
