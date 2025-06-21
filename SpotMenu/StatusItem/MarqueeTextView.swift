import SwiftUI
import AppKit

struct AutoMarqueeTextView: NSViewRepresentable {
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
        nsView.update(text: text, font: font, speed: speed, wrapAround: wrapAround)
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
        [textLayer1, textLayer2].forEach {
            $0.contentsScale = NSScreen.main?.backingScaleFactor ?? 2
            $0.alignmentMode = .left
            $0.truncationMode = .none
            $0.anchorPoint = .zero
            $0.isWrapped = false
            $0.font = font
            $0.fontSize = font.pointSize
            $0.foregroundColor = NSColor.labelColor.cgColor
            layer?.addSublayer($0)
        }
    }

    func update(text: String, font: NSFont, speed: CGFloat, wrapAround: Bool) {
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

        DispatchQueue.main.async { [weak self] in
            self?.layoutText()
        }
    }

    override func layout() {
        super.layout()
        layoutText()
    }

    private func layoutText() {
        guard bounds.width > 0 else { return }

        let textWidth = (text as NSString).size(withAttributes: [.font: font]).width
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
            textLayer1.frame = CGRect(x: 0, y: 0, width: textWidth, height: height)
            textLayer2.frame = CGRect(x: textWidth + 40, y: 0, width: textWidth, height: height)
            textLayer2.isHidden = !wrapAround
            if wrapAround {
                startAnimation(totalWidth: textWidth + 40)
            }
        }
    }

    private func startAnimation(totalWidth: CGFloat) {
        let animation = CABasicAnimation(keyPath: "sublayerTransform.translation.x")
        animation.fromValue = 0
        animation.toValue = -totalWidth
        animation.duration = CFTimeInterval(totalWidth / speed)
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        layer?.add(animation, forKey: "scroll")
        isScrolling = true
    }

    private func stopAnimation() {
        layer?.removeAnimation(forKey: "scroll")
        isScrolling = false
    }
}


#Preview(body: {
    VStack {
        AutoMarqueeTextView(
            text:
                "🎵 This is a looping marquee text that wraps and scrolls infinitely.",
            font: NSFont.systemFont(ofSize: 13, weight: .medium),
            speed: 40,

        )
        .frame(width: 150, height: 20)
        AutoMarqueeTextView(
            text: "short",
            font: .systemFont(ofSize: 13),
            speed: 40,

        )
        .frame(width: 150, height: 20)
    }
    .padding()
})
