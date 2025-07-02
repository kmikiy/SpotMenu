import AppKit
import Foundation

class StatusItemModel: ObservableObject {
    @Published var artist: String = ""
    @Published var title: String = ""
    @Published var isPlaying: Bool = false
    @Published var isLiked: Bool? = nil
    @Published var playerIconName: String = "SpotifyIcon"

    struct DisplayOptions {
        let showIcon: Bool
        let showHeartIcon: Bool
        let showMusicIcon: Bool
        let showCompact: Bool
        let showText: Bool
        let showArtist: Bool
        let showTitle: Bool
        let maxStatusItemWidth: CGFloat
    }

    func computeDisplayOptions(
        menuBarPreferencesModel: MenuBarPreferencesModel,
        musicPlayerPreferencesModel: MusicPlayerPreferencesModel,
        playbackModel: PlaybackModel
    ) -> DisplayOptions {
        let showHeartIcon =
            isLiked == true && playbackModel.isLikingImplemented
            && musicPlayerPreferencesModel.likingEnabled
            && menuBarPreferencesModel.showIsLikedIcon

        let showMusicIcon =
            menuBarPreferencesModel.showIsPlayingIcon && playbackModel.isPlaying

        let showCompact = menuBarPreferencesModel.compactView

        let showArtist = menuBarPreferencesModel.hideArtistWhenPaused

        let showTitle = menuBarPreferencesModel.showTitle

        let hasTextContent = !artist.isEmpty || !title.isEmpty
        let isTextDisplayEnabled = showArtist || showTitle
        let showText = hasTextContent && isTextDisplayEnabled

        let showIcon =
            menuBarPreferencesModel.showAppIcon
            || (!showMusicIcon && !showHeartIcon && !showText)

        return DisplayOptions(
            showIcon: showIcon,
            showHeartIcon: showHeartIcon,
            showMusicIcon: showMusicIcon,
            showCompact: showCompact,
            showText: showText,
            showArtist: showArtist,
            showTitle: showTitle,
            maxStatusItemWidth: menuBarPreferencesModel.maxStatusItemWidth
        )
    }

    func buildText(
        displayOptions: DisplayOptions,
        font: NSFont,
    ) -> String {
        let artistText =
            displayOptions.showArtist ? artist : nil
        let titleText = displayOptions.showTitle ? title : nil

        let label = [artistText, titleText]
            .compactMap { $0 }
            .joined(
                separator: (artistText != nil && titleText != nil) ? " - " : ""
            )

        let spaced =
            label.isEmpty
            ? nil
            : (displayOptions.showMusicIcon ? label : " \(label)")

        let full = [spaced].compactMap { $0 }.joined(separator: " ")

        return truncateText(
            full,
            font: font,
            maxWidth: displayOptions.maxStatusItemWidth
        )
    }

    private func measureTextWidth(_ text: String, font: NSFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        return (text as NSString).size(withAttributes: attributes).width
    }

    private func truncateText(_ text: String, font: NSFont, maxWidth: CGFloat)
        -> String
    {
        let ellipsis = "…"
        if measureTextWidth(text, font: font) <= maxWidth {
            return text
        }

        var truncated = text
        while !truncated.isEmpty
            && measureTextWidth(truncated + ellipsis, font: font) > maxWidth
        {
            truncated = String(truncated.dropLast())
        }

        truncated = truncated.trimmingCharacters(in: .whitespacesAndNewlines)
        if truncated.hasSuffix("-") {
            truncated = String(truncated.dropLast()).trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        }

        return truncated + ellipsis
    }
}
