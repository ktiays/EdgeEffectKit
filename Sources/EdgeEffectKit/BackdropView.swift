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
open class BackdropView: PlatformView {

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
    #elseif canImport(UIKit)
    open override class var layerClass: AnyClass {
        BackdropView.backdropLayerClass
    }
    #endif

    /// Controls whether the backdrop layer updates its luma values.
    @available(iOS 26.0, macOS 26.0, *)
    open var lumaUpdateRate: Double {
        get {
            let fn = #objcMethod("lumaUpdateRate", of: BackdropView.backdropLayerClass, as: (() -> Double).self)
            return fn?(backdropLayer)() ?? 0.0
        }
        set {
            let fn = #objcMethod("setLumaUpdateRate:", of: BackdropView.backdropLayerClass, as: ((Double) -> Void).self)
            fn?(backdropLayer)(newValue)
        }
    }

    /// Enables or disables filtered luma processing for the backdrop effect.
    @available(iOS 26.0, *)
    open var allowsFilteredLuma: Bool {
        get {
            let fn = #objcMethod("allowsFilteredLuma", of: BackdropView.backdropLayerClass, as: (() -> Bool).self)
            return fn?(backdropLayer)() ?? false
        }
        set {
            let fn = #objcMethod("setAllowsFilteredLuma:", of: BackdropView.backdropLayerClass, as: ((Bool) -> Void).self)
            fn?(backdropLayer)(newValue)
        }
    }

    /// Controls whether the backdrop layer continuously tracks luminance values.
    open var tracksLuma: Bool {
        get {
            let fn = #objcMethod("tracksLuma", of: BackdropView.backdropLayerClass, as: (() -> Bool).self)
            return fn?(backdropLayer)() ?? false
        }
        set {
            let fn = #objcMethod("setTracksLuma:", of: BackdropView.backdropLayerClass, as: ((Bool) -> Void).self)
            fn?(backdropLayer)(newValue)
        }
    }

    /// Determines if luma tracking continues when the view is hidden.
    open var tracksLumaWhileHidden: Bool {
        get {
            let fn = #objcMethod("tracksLumaWhileHidden", of: BackdropView.backdropLayerClass, as: (() -> Bool).self)
            return fn?(backdropLayer)() ?? false
        }
        set {
            let fn = #objcMethod("setTracksLumaWhileHidden:", of: BackdropView.backdropLayerClass, as: ((Bool) -> Void).self)
            fn?(backdropLayer)(newValue)
        }
    }

    /// The rectangular region used for luma sampling within the backdrop layer.
    @available(iOS 26.0, *)
    open var lumaSubrect: CGRect {
        get {
            let fn = #objcMethod("lumaSubrect", of: BackdropView.backdropLayerClass, as: (() -> CGRect).self)
            return fn?(backdropLayer)() ?? .zero
        }
        set {
            let fn = #objcMethod("setLumaSubrect:", of: BackdropView.backdropLayerClass, as: ((CGRect) -> Void).self)
            fn?(backdropLayer)(newValue)
        }
    }

    /// The rectangular area that defines the backdrop capture region.
    open var backdropRect: CGRect {
        get {
            let fn = #objcMethod("backdropRect", of: BackdropView.backdropLayerClass, as: (() -> CGRect).self)
            return fn?(backdropLayer)() ?? .zero
        }
        set {
            let fn = #objcMethod("setBackdropRect:", of: BackdropView.backdropLayerClass, as: ((CGRect) -> Void).self)
            fn?(backdropLayer)(newValue)
        }
    }

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

    /// Enables in-place filtering optimization for better performance.
    open var allowsInPlaceFiltering: Bool {
        get {
            let fn = #objcMethod("allowsInPlaceFiltering", of: BackdropView.backdropLayerClass, as: (() -> Bool).self)
            return fn?(backdropLayer)() ?? false
        }
        set {
            let fn = #objcMethod("setAllowsInPlaceFiltering:", of: BackdropView.backdropLayerClass, as: ((Bool) -> Void).self)
            fn?(backdropLayer)(newValue)
        }
    }

    /// Controls whether the backdrop capture uses reduced bit depth for memory optimization.
    open var reducesCaptureBitDepth: Bool {
        get {
            let fn = #objcMethod("reducesCaptureBitDepth", of: BackdropView.backdropLayerClass, as: (() -> Bool).self)
            return fn?(backdropLayer)() ?? false
        }
        set {
            let fn = #objcMethod("setReducesCaptureBitDepth:", of: BackdropView.backdropLayerClass, as: ((Bool) -> Void).self)
            fn?(backdropLayer)(newValue)
        }
    }

    /// When `true`, the backdrop ignores screen clipping boundaries.
    open var ignoresScreenClip: Bool {
        get {
            let fn = #objcMethod("ignoresScreenClip", of: BackdropView.backdropLayerClass, as: (() -> Bool).self)
            return fn?(backdropLayer)() ?? false
        }
        set {
            let fn = #objcMethod("setIgnoresScreenClip:", of: BackdropView.backdropLayerClass, as: ((Bool) -> Void).self)
            fn?(backdropLayer)(newValue)
        }
    }

    /// Determines if the backdrop preallocates screen area for improved performance.
    open var preallocatesScreenArea: Bool {
        get {
            let fn = #objcMethod("preallocatesScreenArea", of: BackdropView.backdropLayerClass, as: (() -> Bool).self)
            return fn?(backdropLayer)() ?? false
        }
        set {
            let fn = #objcMethod("setPreallocatesScreenArea:", of: BackdropView.backdropLayerClass, as: ((Bool) -> Void).self)
            fn?(backdropLayer)(newValue)
        }
    }

    /// The zoom factor applied to the backdrop content.
    open var zoom: CGFloat {
        get {
            let fn = #objcMethod("zoom", of: BackdropView.backdropLayerClass, as: (() -> CGFloat).self)
            return fn?(backdropLayer)() ?? 1.0
        }
        set {
            let fn = #objcMethod("setZoom:", of: BackdropView.backdropLayerClass, as: ((CGFloat) -> Void).self)
            fn?(backdropLayer)(newValue)
        }
    }

    /// The rate at which the backdrop content updates, measured in frames per second.
    open var updateRate: CGFloat {
        get {
            let fn = #objcMethod("updateRate", of: BackdropView.backdropLayerClass, as: (() -> CGFloat).self)
            return fn?(backdropLayer)() ?? 0.0
        }
        set {
            let fn = #objcMethod("setUpdateRate:", of: BackdropView.backdropLayerClass, as: ((CGFloat) -> Void).self)
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
