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
