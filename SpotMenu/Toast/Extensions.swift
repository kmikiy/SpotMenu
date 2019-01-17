//
//  Extensions.swift
//  Toast
//
//  Created by toshi0383 on 2016/10/23.
//
//

import Foundation
#if os(OSX)
    import AppKit
    typealias View = NSView
    typealias Color = NSColor
    typealias Font = NSFont
#elseif os(iOS) || os(tvOS)
    import UIKit
    typealias View = UIView
    typealias Color = UIColor
    typealias Font = UIFont
#endif

extension CGRect {
    static func center(of layer: CALayer) -> CGPoint {
        let parentSize = layer.frame.size
        return CGPoint(x: parentSize.width / 2, y: parentSize.height / 2)
    }

    static func center(of parent: View) -> CGPoint {
        let parentSize = parent.frame.size
        return CGPoint(x: parentSize.width / 2, y: parentSize.height / 2)
    }
}

extension NSString {
    func toast_size(with attributes: [NSAttributedStringKey: Any]?) -> CGSize {
        #if os(OSX)
            return size(withAttributes: attributes)
        #elseif os(iOS) || os(tvOS)
            return size(attributes: attributes)
        #endif
    }
}

extension View {
    var _layer: CALayer {
        #if os(OSX)
            return layer!
        #elseif os(iOS) || os(tvOS)
            return layer
        #endif
    }
}

extension String {
    func size(with fontSize: CGFloat) -> CGSize {
        let attr: [NSAttributedStringKey: Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): Font.systemFont(ofSize: fontSize)]
        let size = NSString(string: self).toast_size(with: attr)
        return size
    }
}
