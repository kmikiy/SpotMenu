// From NicholasBellucci

import Cocoa

open class ScrollingTextView: NSView {
    // MARK: - Open variables

    /// Text to scroll
    open var text: NSString?

    /// Font for scrolling text
    open var font: NSFont?

    /// Scrolling text color
    open var textColor: NSColor = .headerTextColor

    /// Determines if the text should be delayed before starting scroll
    open var isDelayed: Bool = true

    /// Spacing between the tail and head of the scrolling text
    open var spacing: CGFloat = 20

    /// Amount of time the text is delayed before scrolling
    open var delay: TimeInterval = 2 {
        didSet {
            updateTraits()
        }
    }

    /// Length of the scrolling text view
    open var length: CGFloat = 0 {
        didSet {
            updateTraits()
        }
    }

    /// Speed at which the text scrolls. This number is divided by 100.
    open var speed: Double = 4 {
        didSet {
            updateTraits()
        }
    }

    // MARK: - Private variables
    private var timer: Timer?
    private var point = NSPoint(x: 0, y: 0)
    private var timeInterval: TimeInterval?

    private(set) var stringSize = NSSize(width: 0, height: 0) {
        didSet {
            point.x = 0
        }
    }

    private var timerSpeed: Double? {
        return speed / 100
    }

    private lazy var textFontAttributes: [NSAttributedString.Key: Any] = {
        return [NSAttributedString.Key.font: font ?? NSFont.systemFont(ofSize: 14)]
    }()

    // MARK: - Open functions

    /**
     Sets up the scrolling text view

     - Parameters:
     - string: The string that will be used as the text in the view
     */
    open func setup(string: String) {
        text = string as NSString
        stringSize = text?.size(withAttributes: textFontAttributes) ?? NSSize(width: 0, height: 0)
        setNeedsDisplay(NSRect(x: 0, y: 0, width: frame.width, height: frame.height))
        updateTraits()
    }
}

// MARK: - Private extension
private extension ScrollingTextView {
    func setSpeed(newInterval: TimeInterval) {
        clearTimer()
        timeInterval = newInterval

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
            clearTimer()
            point.x = 0
        }
    }

    func updateTraits() {
        clearTimer()

        if stringSize.width > length {
            guard let speed = timerSpeed else { return }
            if #available(OSX 10.12, *), isDelayed {
                timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { [weak self] timer in
                    self?.setSpeed(newInterval: speed)
                })
            } else {
                setSpeed(newInterval: speed)
            }
        } else {
            setSpeed(newInterval: 0.0)
        }
    }

    func clearTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc
    func update(_ sender: Timer) {
        point.x = point.x - 1
        setNeedsDisplay(NSRect(x: 0, y: 0, width: frame.width, height: frame.height))
    }
}

// MARK: - Overrides
extension ScrollingTextView {
    override open func draw(_ dirtyRect: NSRect) {
        if point.x + stringSize.width < 0 {
            point.x += stringSize.width + spacing
        }

        textFontAttributes[NSAttributedString.Key.foregroundColor] = textColor
        text?.draw(at: point, withAttributes: textFontAttributes)

        if point.x < 0 {
            var otherPoint = point
            otherPoint.x += stringSize.width + spacing
            text?.draw(at: otherPoint, withAttributes: textFontAttributes)
        }
    }

    override open func layout() {
        super.layout()
        point.y = (frame.height - stringSize.height) / 2
    }
}
