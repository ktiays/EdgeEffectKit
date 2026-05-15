//
//  Created by ktiays on 2026/5/15.
//  Copyright (c) 2026 ktiays. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public typealias PlatformView = UIView
public typealias PlatformColor = UIColor
public typealias PlatformImage = UIImage

extension UIView {
    
    var ensureLayer: CALayer { layer }
}
#elseif canImport(AppKit)
import AppKit

public typealias PlatformView = NSView
public typealias PlatformColor = NSColor
public typealias PlatformImage = NSImage

public class FlippedView: NSView {
    
    public override var isFlipped: Bool { true }
}

extension NSView {
    
    var ensureLayer: CALayer {
        wantsLayer = true
        return layer!
    }
    
    func setNeedsLayout() {
        needsLayout = true
    }
}
#else
#error("Unsupported platform")
#endif
