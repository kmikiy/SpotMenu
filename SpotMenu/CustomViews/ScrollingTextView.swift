// Implementation
// From NicholasBellucci

import Cocoa

class ScrollingTextView: NSView {
    var text: NSString?
    var font: NSFont?
    var stringWidth: CGFloat = 0
    private var timer: Timer?
    private var point = NSPoint(x: 0, y: 3)
    private var timeInterval: TimeInterval?
    
    private lazy var textFontAttributes: [NSAttributedString.Key: Any] = {
        return [NSAttributedString.Key.font: font ?? NSFont.systemFont(ofSize: 14),
                NSAttributedString.Key.foregroundColor: NSColor.headerTextColor]
    }()
    
    func setup(string: String, width: CGFloat,  speed: Double = 0.0) {
        text = string as NSString
        stringWidth = text?.size(withAttributes: textFontAttributes).width ?? 0
        
        if stringWidth > width {
            setSpeed(newInterval: speed)
        } else {
            setSpeed(newInterval: 0.0)
        }
        
        setNeedsDisplay(NSRect(x: 0, y: 0, width: frame.width, height: frame.height))
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if point.x + stringWidth < 0 {
            self.point.x += stringWidth + 20
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
        if newInterval != timeInterval {
            timeInterval = newInterval
            timer?.invalidate()
            timer = nil
            
            guard let timeInterval = timeInterval else { return }
            if timer == nil, timeInterval > 0.0, text != nil {
                if #available(OSX 10.12, *) {
                    timer = Timer.scheduledTimer(withTimeInterval: newInterval, repeats: true, block: { [weak self] _ in
                        guard let sself = self else { return }
                        sself.point.x = sself.point.x - 1
                        sself.setNeedsDisplay(NSRect(x: 0, y: 0, width: sself.frame.width, height: sself.frame.height))
                    })
                } else {
                    // Fallback on earlier versions
                }
                
                guard let timer = timer else { return }
                RunLoop.main.add(timer, forMode: .commonModes)
            } else {
                timer?.invalidate()
                point.x = 0
            }
        }
    }
}

// Usage

private var scrollingTextView: ScrollingTextView = {
    let textView = ScrollingTextView()
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.font = NSFont.systemFont(ofSize: 13)
    textView.setup(string: "This is a long string", width: 200, speed: 0.04)
    return textView
}()
