//
//  MenuBar.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2018. 04. 17..
//  Copyright © 2018. KM. All rights reserved.
//

import Cocoa

class MenuBar: NSView {
    
    @IBOutlet weak var longLabel: NSTextField!

    func updateTitle(title: String) {
        longLabel.stringValue = " " + title + " " // just some padding. TODO: make rect larger instead of adding strings
        longLabel.frame = CGRect(origin: CGPoint(x: 0, y: 3), size: longLabel.stringValue.sizeOfString(usingFont: longLabel.font!))
        startMarqueeLabelAnimation()
    }
    
    private func startMarqueeLabelAnimation() {
        DispatchQueue.main.async(execute: {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = TimeInterval(self.longLabel.stringValue.widthOfString(usingFont: self.longLabel.font!))/30
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                self.longLabel.animator().frame = self.longLabel.frame.offsetBy(dx: -self.longLabel.frame.width, dy: 0)
            }, completionHandler: {
                self.longLabel.frame = self.longLabel.frame.offsetBy(dx: self.longLabel.frame.width, dy: 0)
            })
        })
    }
}

// TODO put extensions in separate files

extension String {
    func widthOfString(usingFont font: NSFont) -> CGFloat {
        let fontAttributes = [NSAttributedStringKey.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: NSFont) -> CGFloat {
        let fontAttributes = [NSAttributedStringKey.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func sizeOfString(usingFont font: NSFont) -> CGSize {
        let fontAttributes = [NSAttributedStringKey.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}


extension NSView {
    class func fromNib<T: NSView>(name: String) -> T {
        var topLevelObjects : NSArray?
        if Bundle.main.loadNibNamed(NSNib.Name(rawValue: name), owner: nil, topLevelObjects: &topLevelObjects){
            return (topLevelObjects!.first(where: { $0 is NSView }) as? T)!
        }
        return NSView() as! T
    }
}
