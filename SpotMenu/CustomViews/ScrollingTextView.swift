// Implementation
// From NicholasBellucci

import Cocoa

class ScrollingTextView: NSView {
    var text: NSString?
    var font: NSFont?
    var textColor: NSColor?
    var delayed: Bool = true

    var length: CGFloat = 0 {
        didSet {
            updatePreferences()
        }
    }

    var speed: Double = 4 {
        didSet {
            updatePreferences()
        }
    }

    private var timer: Timer?
    private var point = NSPoint(x: 0, y: 3)
    private var timeInterval: TimeInterval?

    private(set) var stringWidth: CGFloat = 0 {
        didSet {
            point.x = 0
        }
    }

    private var relativeSpeed: Double? {
        return speed / 100
    }

    private lazy var textFontAttributes: [NSAttributedString.Key: Any] = {
        return [NSAttributedString.Key.font: font ?? NSFont.systemFont(ofSize: 14)]
    }()

    func setup(string: String) {
        text = string as NSString
        stringWidth = text?.size(withAttributes: textFontAttributes).width ?? 0
        setNeedsDisplay(NSRect(x: 0, y: 0, width: frame.width, height: frame.height))
        updatePreferences()
    }

    override func draw(_ dirtyRect: NSRect) {
        if point.x + stringWidth < 0 {
            self.point.x += stringWidth + 20
        }

        if let color = textColor {
            textFontAttributes[NSAttributedString.Key.foregroundColor] = color
        } else {
            textFontAttributes[NSAttributedString.Key.foregroundColor] = NSColor.headerTextColor
        }

        text?.draw(at: point, withAttributes: textFontAttributes)

        if point.x < 0 {
            var otherPoint = point
            otherPoint.x += stringWidth + 20
            text?.draw(at: otherPoint, withAttributes: textFontAttributes)
        }
    }
}

private extension ScrollingTextView {
    func setSpeed(newInterval: TimeInterval) {
        timeInterval = newInterval
        timer?.invalidate()
        timer = nil

        guard let timeInterval = timeInterval else { return }
        if timer == nil, timeInterval > 0.0, text != nil {
            if #available(OSX 10.12, *) {
                timer = Timer.scheduledTimer(timeInterval: newInterval, target: self, selector: #selector(update(_:)), userInfo: nil, repeats: true)

                guard let timer = timer else { return }
                RunLoop.main.add(timer, forMode: .commonModes)
            } else {
                // Fallback on earlier versions
            }
        } else {
            timer?.invalidate()
            point.x = 0
        }
    }

    func updatePreferences() {
        timer?.invalidate()
        if stringWidth > length {
            if #available(OSX 10.12, *), delayed {
                timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { timer in
                    self.setSpeed(newInterval: self.relativeSpeed ?? 0)
                })
            } else {
                setSpeed(newInterval: relativeSpeed ?? 0)
            }
        } else {
            setSpeed(newInterval: 0.0)
        }
    }

    @objc
    func update(_ sender: Timer) {
        point.x = point.x - 1
        setNeedsDisplay(NSRect(x: 0, y: 0, width: frame.width, height: frame.height))
    }
}
