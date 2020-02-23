//
//  Toast.swift
//  Toast
//
//  Created by toshi0383 on 2016/10/23.
//
//

import Foundation
import ObjectiveC
#if os(OSX)
    import AppKit
#elseif os(iOS) || os(tvOS)
    import UIKit
#endif

enum Position {
    case center
}

public protocol Style {
    var fontSize: CGFloat { get }
    var horizontalMargin: CGFloat { get }
    var verticalMargin: CGFloat { get }
    var cornerRadius: CGFloat { get }
    #if os(iOS) || os(tvOS)
        var font: UIFont { get }
        var backgroundColor: UIColor { get }
        var foregroundColor: UIColor { get }
    #elseif os(OSX)
        var font: NSFont { get }
        var backgroundColor: NSColor { get }
        var foregroundColor: NSColor { get }
    #endif
    var fadeInOutDuration: CGFloat { get }
    var fadeInOutDelay: CGFloat { get }
    var labelOriginWithMargin: CGPoint { get }
    var activitySize: CGSize { get }
}

extension Style {
    public var labelOriginWithMargin: CGPoint {
        return CGPoint(x: horizontalMargin, y: verticalMargin)
    }

    #if os(iOS)
        public var fontSize: CGFloat { return 16 }
        public var font: UIFont {
            return Font.systemFont(ofSize: fontSize)
        }
        public var horizontalMargin: CGFloat { return 5 }
        public var verticalMargin: CGFloat { return 5 }
        public var cornerRadius: CGFloat { return 6 }
        public var backgroundColor: UIColor { return .black }
        public var foregroundColor: UIColor { return .white }
        public var activitySize: CGSize { return CGSize(width: 100, height: 100) }
    #elseif os(tvOS)
        public var fontSize: CGFloat { return 42 }
        public var font: UIFont {
            return Font.systemFont(ofSize: fontSize)
        }
        public var horizontalMargin: CGFloat { return 15 }
        public var verticalMargin: CGFloat { return 10 }
        public var cornerRadius: CGFloat { return 6 }
        public var backgroundColor: UIColor { return .black }
        public var foregroundColor: UIColor { return .white }
        public var activitySize: CGSize { return CGSize(width: 180, height: 180) }
    #elseif os(OSX)
        public var fontSize: CGFloat { return 36 }
        public var font: NSFont {
            return NSFont.systemFont(ofSize: fontSize)
        }
        public var horizontalMargin: CGFloat { return 10 }
        public var verticalMargin: CGFloat { return 5 }
        public var cornerRadius: CGFloat { return 6 }
        public var backgroundColor: NSColor { return .black }
        public var foregroundColor: NSColor { return .white }
        public var activitySize: CGSize { return CGSize(width: 100, height: 100) }
    #endif
    public var fadeInOutDuration: CGFloat { return 1.0 }
    public var fadeInOutDelay: CGFloat { return 3.0 }
}

public struct DefaultStyle: Style {
    public static let shared = DefaultStyle()
}

public struct IndicatorStyle: Style {
    public static let shared = IndicatorStyle()
    public var fadeInOutDuration: CGFloat = 0.1
    public var fadeInOutDelay: CGFloat = 0.0
    #if os(iOS) || os(tvOS)
        public var backgroundColor: UIColor
    #elseif os(OSX)
        public var backgroundColor: NSColor
    #endif
    init() {
        backgroundColor = Color.black.withAlphaComponent(0.5)
    }

    #if os(tvOS)
        public var cornerRadius: CGFloat { return 18 }
    #endif
}

private struct ToastKeys {
    static var ActiveToast = "TSToastActiveToastKey"
    static var ActivityView = "TSToastActivityViewKey"
}

class ToastView: View {
    private var message: String
    private var labelSize: CGSize
    private var style: Style
    private var container: CALayer? = nil
    private var text: CATextLayer? = nil
    private var anim: CABasicAnimation? = nil
    public var fadeDelay = 3.0

    init(message: String) {
        self.message = message
        style = DefaultStyle()
        labelSize = message.size(with: style.fontSize)
        let size = CGSize(
            width: labelSize.width + style.horizontalMargin * 2,
            height: labelSize.height + style.verticalMargin * 2
        )
        let rect = CGRect(origin: .zero, size: size)
        super.init(frame: rect)
        #if os(OSX)
            wantsLayer = true
        #endif
    }

    public func changeText(_ message: String) {
        self.message = message
        style = DefaultStyle()
        labelSize = message.size(with: style.fontSize)
        let size = CGSize(
                width: labelSize.width + style.horizontalMargin * 2,
                height: labelSize.height + style.verticalMargin * 2
        )
        //let rect = CGRect(origin: .zero, size: size)
        setFrameSize(size)
        setFrameOrigin(.zero)
        #if os(OSX)
        wantsLayer = true
        #endif

        if superview != nil {
            frame = superview!.bounds
            let rect = CGRect(origin: style.labelOriginWithMargin, size: labelSize)
            let sizeWithMargin = CGSize(
                    width: rect.width + style.horizontalMargin * 2,
                    height: rect.height + style.verticalMargin * 2
            )
            let rectWithMargin = CGRect(
                    origin: .zero, // position is manipulated later anyways
                    size: sizeWithMargin
            )
            // outside Container
            container!.frame = rectWithMargin
            container!.position = CGRect.center(of: superview!)
            // inside TextLayer
            text!.frame = rect
            text!.position = CGRect.center(of: container!)
            text!.string = message
        }
        for key in _layer.animationKeys() ?? [] {
            print("key: \(key)")
        }
        fadeDelay = 3.0
        let currentLayerTime = _layer.convertTime(CACurrentMediaTime(), from: nil)
        anim!.beginTime = currentLayerTime + CFTimeInterval(fadeDelay)
        _layer.removeAnimation(forKey: "hide animation")
        _layer.add(anim!, forKey: "hide animation")
    }

    required init?(coder _: NSCoder) { fatalError() }

    #if os(iOS) || os(tvOS)
        override func didMoveToSuperview() {
            super.didMoveToSuperview()
            if superview != nil {
                configure()
            }
        }
    #elseif os(OSX)
        override func viewDidMoveToSuperview() {
            super.viewDidMoveToSuperview()
            if superview != nil {
                configure()
            }
        }
    #endif

    private func configure() {
        frame = superview!.bounds
        let rect = CGRect(origin: style.labelOriginWithMargin, size: labelSize)
        let sizeWithMargin = CGSize(
            width: rect.width + style.horizontalMargin * 2,
            height: rect.height + style.verticalMargin * 2
        )
        let rectWithMargin = CGRect(
            origin: .zero, // position is manipulated later anyways
            size: sizeWithMargin
        )
        // outside Container
        container = CALayer()
        container!.frame = rectWithMargin
        container!.position = CGRect.center(of: superview!)
        container!.backgroundColor = NSColor.black.withAlphaComponent(0.75).cgColor//style.backgroundColor.cgColor
        container!.cornerRadius = style.cornerRadius
        _layer.addSublayer(container!)
        // inside TextLayer
        text = CATextLayer()
        text!.frame = rect
        text!.position = CGRect.center(of: container!)
        text!.string = message
        text!.font = Font.systemFont(ofSize: style.fontSize)
        text!.fontSize = style.fontSize
        text!.alignmentMode = "center"
        text!.foregroundColor = style.foregroundColor.cgColor
        text!.contentsScale = _layer.contentsScale // For Retina Display
        container!.addSublayer(text!)
    }

    public func addAnimation(show: Bool) {

        let from = show ? 0 : 1
        let to = 1 - from
        let key = show ? "show animation" : "hide animation"

        anim = CABasicAnimation(keyPath: "opacity")
        let timing = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        anim!.timingFunction = timing
        let currentLayerTime = _layer.convertTime(CACurrentMediaTime(), from: nil)
        anim!.beginTime = currentLayerTime + CFTimeInterval(fadeDelay)
        anim!.duration = CFTimeInterval(style.fadeInOutDuration)
        anim!.fromValue = from
        anim!.toValue = to
        anim!.isRemovedOnCompletion = false
        anim!.delegate = HideAnimationDelegate.delegate(forView: self)

        _layer.add(anim!, forKey: key)
    }

}

class ActivityView: View {
    let _indicator = _Indicator.create()
    var style: Style
    init() {
        style = IndicatorStyle()
        let rect = CGRect(origin: .zero, size: .zero)
        super.init(frame: rect)
        #if os(OSX)
            wantsLayer = true
        #endif
    }

    required init?(coder _: NSCoder) { fatalError() }

    #if os(iOS) || os(tvOS)
        override func didMoveToSuperview() {
            super.didMoveToSuperview()
            if superview != nil {
                configure()
            }
        }
    #elseif os(OSX)
        override func viewDidMoveToSuperview() {
            super.viewDidMoveToSuperview()
            if superview != nil {
                configure()
            }
        }
    #endif

    private func configure() {
        frame = superview!.bounds
        let size = style.activitySize
        let origin = CGPoint(x: frame.width / 2 - size.width / 2, y: frame.height / 2 - size.height / 2)

        #if os(iOS) || os(tvOS)
            frame = CGRect(origin: origin, size: size)
            _indicator.frame = CGRect(origin: .zero, size: size)
            _layer.backgroundColor = style.backgroundColor.cgColor
            _layer.cornerRadius = style.cornerRadius
            _layer.opacity = 0.8
        #elseif os(OSX)
            _indicator.frame = CGRect(origin: origin, size: size)
            _layer.backgroundColor = Color.gray.withAlphaComponent(0.6).cgColor
        #endif
        addSubview(_indicator)
        _indicator._startAnimating()
    }
}

#if os(iOS) || os(tvOS)
    typealias _Indicator = UIActivityIndicatorView
#elseif os(OSX)
    typealias _Indicator = NSProgressIndicator
#endif

extension _Indicator {
    static func create() -> _Indicator {
        #if os(iOS) || os(tvOS)
            return _Indicator(activityIndicatorStyle: .whiteLarge)
        #elseif os(OSX)
            return _Indicator()
        #endif
    }

    func _startAnimating() {
        #if os(iOS) || os(tvOS)
            startAnimating()
        #elseif os(OSX)
            startAnimation(nil)
        #endif
    }
}

extension View {

    // MARK: Toast Message

    private static var _myComputedProperty = [String:ToastView]()

    var myComputedProperty:ToastView? {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return View._myComputedProperty[tmpAddress] ?? nil
        }
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            View._myComputedProperty[tmpAddress] = newValue
        }
    }

    public func changeToastText(_ message: String) {
        if let toast = myComputedProperty {
            toast.changeText(message)
        }
    }
    public func makeToast(_ message: String, _ fadeDelay: Double) {
        let toast = ToastView(message: message)
        myComputedProperty = toast
        toast.fadeDelay = fadeDelay
        addSubview(toast)
        toast.addAnimation(show: false)
    }

    // MARK: Indicator

    public func makeToastActivity() {
        let activityView = ActivityView()
        objc_setAssociatedObject(self, &ToastKeys.ActivityView, activityView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        activityView._layer.opacity = 0.0
        addSubview(activityView)
        showAnimation(view: activityView, style: IndicatorStyle.shared)
    }

    public func hideToastActivity() {
        if let activityView = objc_getAssociatedObject(self, &ToastKeys.ActivityView) as? View {
            hideAnimation(view: activityView, style: IndicatorStyle.shared)
        }
    }
}
