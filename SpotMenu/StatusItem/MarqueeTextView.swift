import AppKit
import SwiftUI

struct AutoMarqueeTextView: View {
    var text: String
    var font: NSFont = .systemFont(ofSize: 13)
    var speed: CGFloat = 40
    var wrapAround: Bool = true

    @State private var shouldScroll = false
    @State private var availableWidth: CGFloat = 0
    @State private var textWidth: CGFloat = 0

    var body: some View {
        ZStack {
            if shouldScroll {
                MarqueeTextView(
                    text: text,
                    font: font,
                    speed: speed,
                    wrapAround: wrapAround
                )
            } else {
                Text(text)
                    .font(Font(font))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        availableWidth = proxy.size.width
                        measureTextWidth()
                    }
                    .onChange(of: proxy.size.width) {
                        availableWidth = proxy.size.width
                        measureTextWidth()
                    }
            }
        )
    }

    private func measureTextWidth() {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = (text as NSString).size(withAttributes: attributes)
        textWidth = size.width
        shouldScroll = textWidth > availableWidth
    }
}

struct MarqueeTextView: NSViewRepresentable {
    var text: String
    var font: NSFont = .systemFont(ofSize: 13)
    var speed: CGFloat = 40
    var wrapAround: Bool = true

    func makeNSView(context: Context) -> MarqueeView {
        let view = MarqueeView()
        view.setup(font: font)
        return view
    }

    func updateNSView(_ nsView: MarqueeView, context: Context) {
        nsView.update(
            text: text,
            font: font,
            speed: speed,
            wrapAround: wrapAround
        )
    }
}

// MARK: - Custom NSView

class MarqueeView: NSView {
    private let textLayer1 = CATextLayer()
    private let textLayer2 = CATextLayer()
    private var text: String = ""
    private var font: NSFont = .systemFont(ofSize: 13)
    private var speed: CGFloat = 40
    private var wrapAround: Bool = true

    private var isScrolling = false
    private var animationDelayWorkItem: DispatchWorkItem?
    private var previousBoundsSize: CGSize?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer = CALayer()
        layer?.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(font: NSFont) {
        self.font = font
        for textLayer in [textLayer1, textLayer2] {
            textLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2
            textLayer.alignmentMode = .left
            textLayer.truncationMode = .none
            textLayer.anchorPoint = .zero
            textLayer.isWrapped = false
            textLayer.font = font
            textLayer.fontSize = font.pointSize
            textLayer.foregroundColor =
                resolvedLabelColor(for: self.effectiveAppearance).cgColor
            layer?.addSublayer(textLayer)
        }
    }

    func update(text: String, font: NSFont, speed: CGFloat, wrapAround: Bool) {
        let textChanged = (self.text != text)
        let fontChanged = (self.font != font)

        self.text = text
        self.font = font
        self.speed = speed
        self.wrapAround = wrapAround

        textLayer1.string = text
        textLayer2.string = text
        textLayer1.font = font
        textLayer2.font = font
        textLayer1.fontSize = font.pointSize
        textLayer2.fontSize = font.pointSize

        let resolvedColor = resolvedLabelColor(for: effectiveAppearance).cgColor
        textLayer1.foregroundColor = resolvedColor
        textLayer2.foregroundColor = resolvedColor

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let currentSize = self.bounds.size
            if self.previousBoundsSize != currentSize || textChanged
                || fontChanged
            {
                self.previousBoundsSize = currentSize
                self.layoutText()
            }
        }
    }

    override func layout() {
        super.layout()
        let currentSize = bounds.size
        if previousBoundsSize != currentSize {
            previousBoundsSize = currentSize
            layoutText()
        }
        let resolvedColor = resolvedLabelColor(for: effectiveAppearance).cgColor
        textLayer1.foregroundColor = resolvedColor
        textLayer2.foregroundColor = resolvedColor
    }

    private func layoutText() {
        guard bounds.width > 0 else { return }

        let textWidth = (text as NSString).size(withAttributes: [.font: font])
            .width
        let height = bounds.height

        stopAnimation()

        if textWidth <= bounds.width {
            // Center text if it fits
            textLayer1.frame = CGRect(
                x: (bounds.width - textWidth) / 2,
                y: 0,
                width: textWidth,
                height: height
            )
            textLayer2.isHidden = true
        } else {
            // Scroll if it overflows
            textLayer1.frame = CGRect(
                x: 0,
                y: 0,
                width: textWidth,
                height: height
            )
            textLayer2.frame = CGRect(
                x: textWidth + 40,
                y: 0,
                width: textWidth,
                height: height
            )
            textLayer2.isHidden = !wrapAround
            if wrapAround {
                startAnimation(totalWidth: textWidth + 40)
            }
        }
    }

    private func startAnimation(totalWidth: CGFloat) {
        // Cancel any pending delayed animation
        animationDelayWorkItem?.cancel()

        let delay: TimeInterval = 2.0
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }

            let animation = CABasicAnimation(
                keyPath: "sublayerTransform.translation.x"
            )
            animation.fromValue = 0
            animation.toValue = -totalWidth
            animation.duration = CFTimeInterval(totalWidth / self.speed)
            animation.repeatCount = .infinity
            animation.timingFunction = CAMediaTimingFunction(name: .linear)

            self.layer?.add(animation, forKey: "scroll")
            self.isScrolling = true
        }

        animationDelayWorkItem = workItem
        DispatchQueue.main.asyncAfter(
            deadline: .now() + delay,
            execute: workItem
        )
    }

    private func stopAnimation() {
        animationDelayWorkItem?.cancel()
        animationDelayWorkItem = nil
        layer?.removeAnimation(forKey: "scroll")
        isScrolling = false
    }
}

// MARK: - Appearance-safe label color fallback

func resolvedLabelColor(for appearance: NSAppearance) -> NSColor {
    if let best = appearance.bestMatch(from: [.darkAqua, .aqua]) {
        return best == .darkAqua ? .white : .black
    }
    return .black
}

// MARK: - Preview

#Preview(body: {
    VStack {
        AutoMarqueeTextView(
            text:
                "🎵 This is a looping marquee text that wraps and scrolls infinitely.",
            font: NSFont.systemFont(ofSize: 13, weight: .medium),
            speed: 40
        )
        .frame(width: 150, height: 20)

        AutoMarqueeTextView(
            text: "short",
            font: .systemFont(ofSize: 13),
            speed: 40
        )
        .frame(width: 150, height: 20)
    }
    .padding()
})
