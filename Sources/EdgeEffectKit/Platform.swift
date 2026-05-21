//
//  Created by ktiays on 2026/5/15.
//  Copyright (c) 2026 ktiays. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public typealias PlatformView = UIView
public typealias PlatformColor = UIColor

extension UIView {
    
    var ensureLayer: CALayer { layer }
    
    var screenScaleFactor: CGFloat {
        return window?.screen.scale ?? 1
    }
}
#elseif canImport(AppKit)
import AppKit

public typealias PlatformView = NSView
public typealias PlatformColor = NSColor

open class FlippedView: NSView {
    
    public override var isFlipped: Bool { true }
    
    public override func layout() {
        super.layout()
        layoutSubviews()
    }
    
    public func layoutSubviews() { }
    
    public func insertSubview(_ view: NSView, belowSubview siblingSubview: NSView) {
        addSubview(view, positioned: .below, relativeTo: siblingSubview)
    }
    
    public func insertSubview(_ view: NSView, aboveSubview siblingSubview: NSView) {
        addSubview(view, positioned: .above, relativeTo: siblingSubview)
    }
}

extension NSView {
    
    var ensureLayer: CALayer {
        wantsLayer = true
        return layer!
    }
    
    var screenScaleFactor: CGFloat {
        return window?.screen?.backingScaleFactor ?? 1
    }
    
    func setNeedsLayout() {
        needsLayout = true
    }
}
#else
#error("Unsupported platform")
#endif
