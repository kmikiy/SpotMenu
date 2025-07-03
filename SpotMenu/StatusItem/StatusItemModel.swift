import AppKit
import Foundation

class StatusItemModel: ObservableObject {
    @Published var artist: String = ""
    @Published var title: String = ""
    @Published var isPlaying: Bool = false
    @Published var isLiked: Bool? = nil

    var showAppIconOnly: Bool {
        return artist.isEmpty && title.isEmpty && !isPlaying
    }

    var isTextEmpty: Bool {
        return artist.isEmpty && title.isEmpty
    }

    func buildText(
        menuBarPreferencesModel: MenuBarPreferencesModel,
        font: NSFont,
    ) -> String {
        let artistText =
            (menuBarPreferencesModel.showArtist && !(artist).isEmpty)
            ? artist : nil
        let titleText =
            (menuBarPreferencesModel.showTitle && !(title).isEmpty)
            ? title : nil

        let label = [artistText, titleText]
            .compactMap { $0 }
            .joined(
                separator: (artistText != nil && titleText != nil) ? " - " : ""
            )

        let spaced =
            label.isEmpty
            ? nil
            : (menuBarPreferencesModel.showIsPlayingIcon ? label : " \(label)")

        let full = [spaced].compactMap { $0 }.joined(separator: " ")

        return truncateText(
            full,
            font: font,
            maxWidth: menuBarPreferencesModel.maxStatusItemWidth
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
