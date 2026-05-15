//
//  Created by ktiays on 2026/4/13.
//  Copyright (c) 2026 ktiays. All rights reserved.
//

#if os(macOS)
import AppKit
import SwiftyRuntime

/// A view that wraps the private `CAPortalLayer` functionality to display a clone of another layer.
///
/// `PortalView` provides a Swift-friendly interface to `CAPortalLayer`, which allows rendering
/// the contents of another layer (source layer) without copying the backing store. This is useful
/// for creating visual effects where the same content needs to appear in multiple locations.
class PortalView: FlippedView {

    /// The private `CAPortalLayer` class loaded at runtime.
    private let portalLayerClass: AnyClass = NSClassFromString("CAPortalLayer")!

    /// The underlying portal layer instance.
    public var portalLayer: CALayer { layer! }

    /// The source layer whose contents this portal displays.
    open var sourceLayer: CALayer? {
        get {
            let fn = #objcMethod("sourceLayer", of: portalLayerClass, as: (() -> CALayer?).self)
            return fn?(portalLayer)()
        }
        set {
            let fn = #objcMethod("setSourceLayer:", of: portalLayerClass, as: ((CALayer?) -> Void).self)
            fn?(portalLayer)(newValue)
        }
    }
    
    open var hidesSourceView: Bool {
        get { hidesSourceLayer }
        set { hidesSourceLayer = newValue }
    }

    /// A Boolean value that determines whether the source layer is hidden when displayed through the portal.
    private var hidesSourceLayer: Bool {
        get {
            let fn = #objcMethod("hidesSourceLayer", of: portalLayerClass, as: (() -> Bool).self)
            return fn?(portalLayer)() ?? false
        }
        set {
            let fn = #objcMethod("setHidesSourceLayer:", of: portalLayerClass, as: ((Bool) -> Void).self)
            fn?(portalLayer)(newValue)
        }
    }

    /// A Boolean value that determines whether the portal matches the opacity of the source layer.
    open var matchesOpacity: Bool {
        get {
            let fn = #objcMethod("matchesOpacity", of: portalLayerClass, as: (() -> Bool).self)
            return fn?(portalLayer)() ?? false
        }
        set {
            let fn = #objcMethod("setMatchesOpacity:", of: portalLayerClass, as: ((Bool) -> Void).self)
            fn?(portalLayer)(newValue)
        }
    }

    /// A Boolean value that determines whether the portal matches the position of the source layer.
    open var matchesPosition: Bool {
        get {
            let fn = #objcMethod("matchesPosition", of: portalLayerClass, as: (() -> Bool).self)
            return fn?(portalLayer)() ?? false
        }
        set {
            let fn = #objcMethod("setMatchesPosition:", of: portalLayerClass, as: ((Bool) -> Void).self)
            fn?(portalLayer)(newValue)
        }
    }

    /// A Boolean value that determines whether the portal matches the transform of the source layer.
    open var matchesTransform: Bool {
        get {
            let fn = #objcMethod("matchesTransform", of: portalLayerClass, as: (() -> Bool).self)
            return fn?(portalLayer)() ?? false
        }
        set {
            let fn = #objcMethod("setMatchesTransform:", of: portalLayerClass, as: ((Bool) -> Void).self)
            fn?(portalLayer)(newValue)
        }
    }

    /// A Boolean value that determines whether backdrop groups are allowed in the portal.
    open var allowsBackdropGroups: Bool {
        get {
            let fn = #objcMethod("allowsBackdropGroups", of: portalLayerClass, as: (() -> Bool).self)
            return fn?(portalLayer)() ?? false
        }
        set {
            let fn = #objcMethod("setAllowsBackdropGroups:", of: portalLayerClass, as: ((Bool) -> Void).self)
            fn?(portalLayer)(newValue)
        }
    }

    /// A Boolean value that determines whether the portal can display content across different displays.
    open var crossDisplay: Bool {
        get {
            let fn = #objcMethod("crossDisplay", of: portalLayerClass, as: (() -> Bool).self)
            return fn?(portalLayer)() ?? false
        }
        set {
            let fn = #objcMethod("setCrossDisplay:", of: portalLayerClass, as: ((Bool) -> Void).self)
            fn?(portalLayer)(newValue)
        }
    }

    /// A Boolean value that determines whether separated content is excluded from the portal.
    open var excludeSeparated: Bool {
        get {
            let fn = #objcMethod("excludeSeparated", of: portalLayerClass, as: (() -> Bool).self)
            return fn?(portalLayer)() ?? false
        }
        set {
            let fn = #objcMethod("setExcludeSeparated:", of: portalLayerClass, as: ((Bool) -> Void).self)
            fn?(portalLayer)(newValue)
        }
    }

    /// A Boolean value that determines whether the portal is allowed in context transforms.
    open var allowedInContextTransform: Bool {
        get {
            let fn = #objcMethod("allowedInContextTransform", of: portalLayerClass, as: (() -> Bool).self)
            return fn?(portalLayer)() ?? false
        }
        set {
            let fn = #objcMethod("setAllowedInContextTransform:", of: portalLayerClass, as: ((Bool) -> Void).self)
            fn?(portalLayer)(newValue)
        }
    }
    
    open var sourceLayerRenderID: UInt64 {
        get {
            let fn = #objcMethod("sourceLayerRenderId", of: portalLayerClass, as: (() -> UInt64).self)
            return fn?(portalLayer)() ?? 0
        }
        set {
            let fn = #objcMethod("setSourceLayerRenderId:", of: portalLayerClass, as: ((UInt64) -> Void).self)
            fn?(portalLayer)(newValue)
        }
    }
    
    open override func makeBackingLayer() -> CALayer {
        let initFn = #objcMethod("init", of: CALayer.self, as: (() -> CALayer).self)!
        return initFn(portalLayerClass.alloc())()
    }
    
    open var sourceView: NSView? {
        didSet {
            updateSourceView()
        }
    }
    
    public init(sourceView: NSView?) {
        self.sourceView = sourceView
        super.init(frame: .zero)
        
        wantsLayer = true
        updateSourceView()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateSourceView() {
        sourceView?.wantsLayer = true
        sourceLayer = sourceView?.layer
    }
}
#endif
