import AppKit
import Foundation

class StaticFadeIn: NSVisualEffectView {
    
    // MARK: - Lifecycle methods
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    deinit {
    }
    
    private func setup() {
        fade()
    }
    
    // MARK: - Private helper methods
    
    private func fade() {
        alphaValue = CGFloat(1)
    }
}
