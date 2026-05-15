//
//  Created by ktiays on 2025/9/24.
//  Copyright (c) 2025 ktiays. All rights reserved.
//

import QuartzCore
import SwiftyRuntime

extension CALayer {

    public var shadowPathIsBounds: Bool {
        get {
            let fn = #objcMethod("shadowPathIsBounds", of: CALayer.self, as: (() -> Bool).self)
            return fn?(self)() ?? false
        }
        set {
            let fn = #objcMethod("setShadowPathIsBounds:", of: CALayer.self, as: ((Bool) -> Void).self)
            fn?(self)(newValue)
        }
    }
    
    public var punchoutShadow: Bool {
        get {
            let fn = #objcMethod("punchoutShadow", of: CALayer.self, as: (() -> Bool).self)
            return fn?(self)() ?? false
        }
        set {
            let fn = #objcMethod("setPunchoutShadow:", of: CALayer.self, as: ((Bool) -> Void).self)
            fn?(self)(newValue)
        }
    }

    public var allowsLimitedHeadroom: Bool {
        get {
            let fn = #objcMethod("allowsLimitedHeadroom", of: CALayer.self, as: (() -> Bool).self)
            return fn?(self)() ?? false
        }
        set {
            let fn = #objcMethod("setAllowsLimitedHeadroom:", of: CALayer.self, as: ((Bool) -> Void).self)
            fn?(self)(newValue)
        }
    }

    public var literalContentsCenter: Bool {
        get {
            let fn = #objcMethod("literalContentsCenter", of: CALayer.self, as: (() -> Bool).self)
            return fn?(self)() ?? false
        }
        set {
            let fn = #objcMethod("setLiteralContentsCenter:", of: CALayer.self, as: ((Bool) -> Void).self)
            fn?(self)(newValue)
        }
    }
    
    public var allowsGroupBlending: Bool {
        get {
            let fn = #objcMethod("allowsGroupBlending", of: CALayer.self, as: (() -> Bool).self)
            return fn?(self)() ?? false
        }
        set {
            let fn = #objcMethod("setAllowsGroupBlending:", of: CALayer.self, as: ((Bool) -> Void).self)
            fn?(self)(newValue)
        }
    }

    public var contentsAlignsToPixels: Bool {
        get {
            let fn = #objcMethod("contentsAlignsToPixels", of: CALayer.self, as: (() -> Bool).self)
            return fn?(self)() ?? false
        }
        set {
            let fn = #objcMethod("setContentsAlignsToPixels:", of: CALayer.self, as: ((Bool) -> Void).self)
            fn?(self)(newValue)
        }
    }

    public var contentsDither: Bool {
        get {
            let fn = #objcMethod("contentsDither", of: CALayer.self, as: (() -> Bool).self)
            return fn?(self)() ?? false
        }
        set {
            let fn = #objcMethod("setContentsDither:", of: CALayer.self, as: ((Bool) -> Void).self)
            fn?(self)(newValue)
        }
    }

    public var invertsMask: Bool {
        get {
            let fn = #objcMethod("invertsMask", of: CALayer.self, as: (() -> Bool).self)
            return fn?(self)() ?? false
        }
        set {
            let fn = #objcMethod("setInvertsMask:", of: CALayer.self, as: ((Bool) -> Void).self)
            fn?(self)(newValue)
        }
    }
    
    public var invertsShadow: Bool {
        get {
            let fn = #objcMethod("invertsShadow", of: CALayer.self, as: (() -> Bool).self)
            return fn?(self)() ?? false
        }
        set {
            let fn = #objcMethod("setInvertsShadow:", of: CALayer.self, as: ((Bool) -> Void).self)
            fn?(self)(newValue)
        }
    }

    public var gain: Float {
        get {
            let fn = #objcMethod("gain", of: CALayer.self, as: (() -> Float).self)
            return fn?(self)() ?? 0.0
        }
        set {
            let fn = #objcMethod("setGain:", of: CALayer.self, as: ((Float) -> Void).self)
            fn?(self)(newValue)
        }
    }

    public var allowedContentsHideSublayers: Bool {
        get {
            let fn = #objcMethod("allowedContentsHideSublayers", of: CALayer.self, as: (() -> Bool).self)
            return fn?(self)() ?? false
        }
        set {
            let fn = #objcMethod("setAllowedContentsHideSublayers:", of: CALayer.self, as: ((Bool) -> Void).self)
            fn?(self)(newValue)
        }
    }

    public var allowsCornerContentsEdgeEffects: Bool {
        get {
            let fn = #objcMethod("allowsCornerContentsEdgeEffects", of: CALayer.self, as: (() -> Bool).self)
            return fn?(self)() ?? false
        }
        set {
            let fn = #objcMethod("setAllowsCornerContentsEdgeEffects:", of: CALayer.self, as: ((Bool) -> Void).self)
            fn?(self)(newValue)
        }
    }
    
    public var compositingFilter: NSObject? {
        get {
            let fn = #objcMethod("compositingFilter", of: CALayer.self, as: (() -> NSObject?).self)
            return fn?(self)()
        }
        set {
            let fn = #objcMethod("setCompositingFilter:", of: CALayer.self, as: ((NSObject?) -> Void).self)
            fn?(self)(newValue)
        }
    }
}
