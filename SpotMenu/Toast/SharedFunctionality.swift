//
//  SharedFunctionality.swift
//  Toast
//
//  Created by toshi0383 on 2016/10/23.
//
//

import Foundation
#if os(OSX)
    import AppKit
#elseif os(iOS) || os(tvOS)
    import UIKit
#endif

fileprivate class HideAnimationDelegate: NSObject, CAAnimationDelegate {
    private weak var view: View?
    fileprivate init(view: View) {
        self.view = view
    }

    fileprivate static func delegate(forView view: View) -> CAAnimationDelegate {
        return HideAnimationDelegate(view: view)
    }

    fileprivate func animationDidStart(_: CAAnimation) {
        view?._layer.opacity = 0.0
    }

    func animationDidStop(_: CAAnimation, finished _: Bool) {
        view?.removeFromSuperview()
        view = nil
    }
}

fileprivate class ShowAnimationDelegate: NSObject, CAAnimationDelegate {
    private weak var view: View?
    fileprivate init(view: View) {
        self.view = view
    }

    fileprivate static func delegate(forView view: View) -> CAAnimationDelegate {
        return ShowAnimationDelegate(view: view)
    }

    fileprivate func animationDidStart(_: CAAnimation) {
        view?._layer.opacity = 1.0
    }

    func animationDidStop(_: CAAnimation, finished _: Bool) {
    }
}

func showAnimation(view: View, style: Style) {
    addAnimation(to: view, style: style, show: true)
}

func hideAnimation(view: View, style: Style) {
    addAnimation(to: view, style: style, show: false)
}

private func addAnimation(to view: View, style: Style, show: Bool) {

    let from = show ? 0 : 1
    let to = 1 - from
    let key = show ? "show animation" : "hide animation"

    let anim = CABasicAnimation(keyPath: "opacity")
    let timing = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    anim.timingFunction = timing
    let currentLayerTime = view._layer.convertTime(CACurrentMediaTime(), from: nil)
    anim.beginTime = currentLayerTime + CFTimeInterval(style.fadeInOutDelay)
    anim.duration = CFTimeInterval(style.fadeInOutDuration)
    anim.fromValue = from
    anim.toValue = to
    anim.isRemovedOnCompletion = false
    anim.delegate = HideAnimationDelegate.delegate(forView: view)

    view._layer.add(anim, forKey: key)
}
