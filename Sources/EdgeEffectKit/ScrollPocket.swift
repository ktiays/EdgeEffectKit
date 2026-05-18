//
//  Created by ktiays on 2025/9/24.
//  Copyright (c) 2025 ktiays. All rights reserved.
//

import CoreImage.CIFilterBuiltins
import QuartzFilters
import With

#if canImport(UIKit)
import UIKit

public typealias _InternalBaseView = UIView
#elseif canImport(AppKit)
import AppKit

public typealias _InternalBaseView = FlippedView
#else
#error("Unsupported platform")
#endif

class ScrollPocket: _InternalBaseView {

    private let pocketMaskedBlur: PocketBlur = .init()
    private let luminanceAdjustment: LuminanceAdjustment = .init()

    var backgroundCapture: PlatformView { _backgroundCapture }
    private let _backgroundCapture: BackdropView = .init()

    open var replayBackgroundColor: PlatformColor? {
        get {
            return luminanceAdjustment.replayBackgroundColor
        }
        set {
            luminanceAdjustment.replayBackgroundColor = newValue
        }
    }

    open var isBlurEnabled: Bool = true {
        didSet {
            if isBlurEnabled != oldValue {
                updatePocketBlur()
            }
        }
    }
    
    private var shadowGenerator: PocketMaskGenerator

    public required init(edge: RectEdge) {
        shadowGenerator = .init(edge: edge)
        super.init(frame: .zero)
        
        #if canImport(UIKit)
        pocketMaskedBlur.isUserInteractionEnabled = false
        luminanceAdjustment.isUserInteractionEnabled = false
        #endif
        addSubview(luminanceAdjustment)

        updatePocketBlur()

        #if canImport(UIKit)
        _backgroundCapture.isUserInteractionEnabled = false
        #endif
        _backgroundCapture.captureOnly = true
        _backgroundCapture.scale = 0.5
        _backgroundCapture.allowsGroupOpacity = true
        _backgroundCapture.groupNamespace = "owningContext"
        let backgroundCaptureGroup = "backgroundGroup-\(ObjectIdentifier(luminanceAdjustment))"
        _backgroundCapture.groupName = backgroundCaptureGroup
        luminanceAdjustment.backdropGroupName = backgroundCaptureGroup
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        
        let edge = shadowGenerator.edge
        shadowGenerator.length = if edge == .top || edge == .bottom { bounds.height } else { bounds.width }
        shadowGenerator.scaleFactor = screenScaleFactor
        
        if pocketMaskedBlur.superview != nil {
            pocketMaskedBlur.maskImage = shadowGenerator.renderShadowImage()
            pocketMaskedBlur.frame = bounds
        }
        luminanceAdjustment.frame = bounds
        luminanceAdjustment.maskImage = shadowGenerator.renderShadowImage()
    }
    
    private func updatePocketBlur() {
        if isBlurEnabled {
            if pocketMaskedBlur.superview == nil {
                #if canImport(UIKit)
                insertSubview(pocketMaskedBlur, belowSubview: luminanceAdjustment)
                #elseif canImport(AppKit)
                addSubview(pocketMaskedBlur, positioned: .below, relativeTo: luminanceAdjustment)
                #else
                #error("Unsupported platform")
                #endif
            }
        } else {
            pocketMaskedBlur.removeFromSuperview()
        }
    }
}

extension ScrollPocket {

    private final class PocketBlur: BackdropView {

        var maskImage: CGImage? {
            didSet {
                guard oldValue != maskImage else {
                    return
                }
                updatePocketBlurFilter(shadowImage: maskImage)
            }
        }
        
        private let pocketMask: PocketMask = .init()
        
        override init(frame rect: CGRect) {
            super.init(frame: rect)

        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func updatePocketBlurFilter(shadowImage: CGImage?) {
            let variableBlur = QuartzFilter.variableBlur()
            variableBlur.radius = 1
            variableBlur.dither = false
            variableBlur.normalizeEdges = true
            variableBlur.maskImage = shadowImage
            ensureLayer.quartzFilters = [variableBlur]
        }
    }
}

extension ScrollPocket {

    private final class LuminanceAdjustment: _InternalBaseView {
        
        var backdropGroupName: String? {
            get {
                return backdropView.groupName
            }
            set {
                backdropView.groupName = newValue
            }
        }
        
        var replayBackgroundColor: PlatformColor? {
            get {
                #if canImport(UIKit)
                backdropView.backgroundColor
                #elseif canImport(AppKit)
                guard let cgColor = backdropView.layer?.backgroundColor else {
                    return nil
                }
                return NSColor(cgColor: cgColor)
                #else
                #error("Unsupported platform")
                #endif
            }
            set {
                #if canImport(UIKit)
                backdropView.backgroundColor = newValue
                #elseif canImport(AppKit)
                backdropView.layer?.backgroundColor = newValue?.cgColor
                #else
                #error("Unsupported platform")
                #endif
            }
        }
        
        var maskImage: CGImage? {
            didSet {
                pocketMask.contentLayer.contents = maskImage
            }
        }

        private let backdropView: BackdropView = .init()
        private let pocketMask: PocketMask = .init()

        override init(frame rect: CGRect) {
            super.init(frame: rect)

            #if canImport(UIKit)
            self.isUserInteractionEnabled = false
            backdropView.alpha = 0.85
            #elseif canImport(AppKit)
            ensureLayer.allowsGroupBlending = true
            #endif

            backdropView.scale = 0.5
            addSubview(backdropView)

            let pocketMaskLayer = pocketMask.ensureLayer
            pocketMaskLayer.allowsGroupBlending = true
            pocketMaskLayer.compositingFilter = "destIn" as NSString
            addSubview(pocketMask)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let bounds = self.bounds
            backdropView.frame = bounds
            pocketMask.frame = bounds
        }
    }
}

extension ScrollPocket {
    
    private final class PocketMask: _InternalBaseView {

        let contentLayer: CALayer = .init()
        private let noAnimationDelegate = NoAnimationDelegate()
        
        override init(frame rect: CGRect) {
            super.init(frame: rect)
            
            contentLayer.delegate = noAnimationDelegate
            ensureLayer.addSublayer(contentLayer)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            contentLayer.frame = bounds
        }
    }
}
