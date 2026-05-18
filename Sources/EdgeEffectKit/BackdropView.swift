//
//  Created by ktiays on 2025/9/24.
//  Copyright (c) 2025 ktiays. All rights reserved.
//

import SwiftyRuntime
import QuartzCore

/// A view that provides backdrop effects using the private `CABackdropLayer`.
///
/// `BackdropView` wraps the undocumented `CABackdropLayer` functionality to enable
/// backdrop blur and visual effects in UIKit applications. This view provides access
/// to various backdrop properties like luma tracking, filtering options, and capture settings.
class BackdropView: PlatformView {

    private static let backdropLayerClass: AnyClass = NSClassFromString("CABackdropLayer")!
    
    private let backdropLayerClass: AnyClass = BackdropView.backdropLayerClass
    
    /// The underlying backdrop layer instance.
    private var backdropLayer: CALayer { ensureLayer }
    
    #if canImport(AppKit)
    open override func makeBackingLayer() -> CALayer {
        let initFn = #objcMethod("init", of: CALayer.self, as: (() -> CALayer).self)!
        return initFn(backdropLayerClass.alloc())()
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
    }
    
    public override func layout() {
        super.layout()
        layoutSubviews()
    }
    
    public func layoutSubviews() { }
    #elseif canImport(UIKit)
    open override class var layerClass: AnyClass {
        BackdropView.backdropLayerClass
    }
    #endif
    
    /// When `true`, the backdrop layer only captures content without applying effects.
    open var captureOnly: Bool {
        get {
            let fn = #objcMethod("captureOnly", of: BackdropView.backdropLayerClass, as: (() -> Bool).self)
            return fn?(backdropLayer)() ?? false
        }
        set {
            let fn = #objcMethod("setCaptureOnly:", of: BackdropView.backdropLayerClass, as: ((Bool) -> Void).self)
            fn?(backdropLayer)(newValue)
        }
    }

    open var scale: CGFloat {
        get {
            let fn = #objcMethod("scale", of: BackdropView.backdropLayerClass, as: (() -> CGFloat).self)
            return fn?(backdropLayer)() ?? 1.0
        }
        set {
            let fn = #objcMethod("setScale:", of: BackdropView.backdropLayerClass, as: ((CGFloat) -> Void).self)
            fn?(backdropLayer)(newValue)
        }
    }
    
    /// An array of Core Animation filters to apply to the contents of the layer and its sublayers.
    open var filters: [Any]? {
        get { backdropLayer.filters }
        set { backdropLayer.filters = newValue }
    }
    
    open var groupName: String? {
        get {
            let fn = #objcMethod("groupName", of: BackdropView.backdropLayerClass, as: (() -> String?).self)
            return fn?(backdropLayer)()
        }
        set {
            let fn = #objcMethod("setGroupName:", of: BackdropView.backdropLayerClass, as: ((String?) -> Void).self)
            fn?(backdropLayer)(newValue)
        }
    }
    
    open var groupNamespace: String? {
        get {
            let fn = #objcMethod("groupNamespace", of: BackdropView.backdropLayerClass, as: (() -> String?).self)
            return fn?(backdropLayer)()
        }
        set {
            let fn = #objcMethod("setGroupNamespace:", of: BackdropView.backdropLayerClass, as: ((String?) -> Void).self)
            fn?(backdropLayer)(newValue)
        }
    }
    
    /// A Boolean indicating whether the layer is allowed to composite itself as a group separate from its parent.
    open var allowsGroupOpacity: Bool {
        get { backdropLayer.allowsGroupOpacity }
        set { backdropLayer.allowsGroupOpacity = newValue }
    }
}
