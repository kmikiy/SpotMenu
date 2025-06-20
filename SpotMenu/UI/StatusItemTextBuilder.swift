import AppKit

struct StatusItemTextBuilder {
    static func buildText(
        artist: String?,
        title: String?,
        isPlaying: Bool,
        showArtist: Bool,
        showTitle: Bool,
        showIsPlayingIcon: Bool,
        font: NSFont,
        maxWidth: CGFloat
    ) -> String {
        let icon = (showIsPlayingIcon && isPlaying) ? "♫" : nil
        let artistText = (showArtist && !(artist ?? "").isEmpty) ? artist : nil
        let titleText = (showTitle && !(title ?? "").isEmpty) ? title : nil

        let label = [artistText, titleText]
            .compactMap { $0 }
            .joined(separator: (artistText != nil && titleText != nil) ? " - " : "")

        let spaced = label.isEmpty
            ? nil
            : (showIsPlayingIcon ? label : " \(label)")

        let full = [icon, spaced].compactMap { $0 }.joined(separator: " ")

        return truncateText(full, font: font, maxWidth: maxWidth)
    }

    static func measureTextWidth(_ text: String, font: NSFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        return (text as NSString).size(withAttributes: attributes).width
    }

    static func truncateText(_ text: String, font: NSFont, maxWidth: CGFloat) -> String {
        let ellipsis = "…"
        if measureTextWidth(text, font: font) <= maxWidth {
            return text
        }

        var truncated = text
        while !truncated.isEmpty && measureTextWidth(truncated + ellipsis, font: font) > maxWidth {
            truncated = String(truncated.dropLast())
        }

        truncated = truncated.trimmingCharacters(in: .whitespacesAndNewlines)
        if truncated.hasSuffix("-") {
            truncated = String(truncated.dropLast()).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return truncated + ellipsis
    }
}
