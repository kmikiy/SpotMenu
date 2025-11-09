import SwiftUI

struct PlaybackAppearancePreferencesView: View {
    @ObservedObject var model: PlaybackAppearancePreferencesModel
    @ObservedObject var musicPlayerPreferencesModel: MusicPlayerPreferencesModel
    @ObservedObject var playbackModel: PlaybackModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                Text("Hover Tint Color")
                Spacer()
                ColorPicker(
                    "",
                    selection: Binding(
                        get: { Color(model.hoverTintColor) },
                        set: { model.hoverTintColor = NSColor($0) }
                    )
                )
            }

            HStack {
                Text("Foreground Color")
                Spacer()
                Picker("", selection: $model.foregroundColor) {
                    ForEach(
                        PlaybackAppearancePreferencesModel.ForegroundColorOption
                            .allCases
                    ) { option in
                        Text(option.rawValue.capitalized).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 100)
            }

            HStack {
                Text("Blur Intensity")
                Spacer()
                Slider(value: $model.blurIntensity, in: 0...1).frame(width: 220)
            }

            HStack {
                Text("Hover Tint Opacity")
                Spacer()
                Slider(value: $model.hoverTintOpacity, in: 0...1).frame(
                    width: 220
                )
            }

            HStack {
                Spacer()
                PlaybackView(
                    model: playbackModel,
                    preferences: model,
                    musicPlayerPreferencesModel: musicPlayerPreferencesModel
                )
                Spacer()
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: 600)
        .padding(20)
    }
    }
}

#Preview {
    PlaybackAppearancePreferencesView(
        model: PlaybackAppearancePreferencesModel(),
        musicPlayerPreferencesModel: MusicPlayerPreferencesModel(),
        playbackModel: PlaybackModel(preferences: MusicPlayerPreferencesModel())
    )
}
