//
//  Created by ktiays on 2025/9/24.
//  Copyright (c) 2025 ktiays. All rights reserved.
//

import CoreImage.CIFilterBuiltins
import QuartzFilters
import With

#if canImport(UIKit)
import CEdgeEffectKit
import UIKit

public typealias PocketElementView = UIView
#elseif canImport(AppKit)
import AppKit

public typealias PocketElementView = FlippedView
#else
#error("Unsupported platform")
#endif

public class ScrollPocket: PocketElementView {

    private let edge: RectEdge
    private let pocketMaskedBlur: PocketBlur
    private let luminanceAdjustment: LuminanceAdjustment

    public let backgroundCapture: BackdropView = .init()

    open var replayBackgroundColor: PlatformColor? {
        get {
            #if canImport(UIKit)
            luminanceAdjustment.backdropView.backgroundColor
            #elseif canImport(AppKit)
            guard let cgColor = luminanceAdjustment.backdropView.layer?.backgroundColor else {
                return nil
            }
            return NSColor(cgColor: cgColor)
            #else
            #error("Unsupported platform")
            #endif
        }
        set {
            #if canImport(UIKit)
            luminanceAdjustment.backdropView.backgroundColor = newValue
            #elseif canImport(AppKit)
            luminanceAdjustment.backdropView.layer?.backgroundColor = newValue?.cgColor
            #else
            #error("Unsupported platform")
            #endif
        }
    }

    open var isBlurEnabled: Bool = true {
        didSet {
            if isBlurEnabled != oldValue {
                updatePocketBlur()
            }
        }
    }

    public required init(edge: RectEdge) {
        self.edge = edge
        pocketMaskedBlur = .init(edge: edge)
        luminanceAdjustment = .init(edge: edge)
        super.init(frame: .zero)
        
        #if canImport(UIKit)
        pocketMaskedBlur.isUserInteractionEnabled = false
        luminanceAdjustment.isUserInteractionEnabled = false
        #endif
        addSubview(luminanceAdjustment)

        updatePocketBlur()

        #if canImport(UIKit)
        backgroundCapture.isUserInteractionEnabled = false
        #endif
        backgroundCapture.captureOnly = true
        backgroundCapture.scale = 0.5
        backgroundCapture.allowsGroupOpacity = true
        backgroundCapture.groupNamespace = "owningContext"
        let backgroundCaptureGroup = "backgroundGroup-\(ObjectIdentifier(luminanceAdjustment))"
        backgroundCapture.groupName = backgroundCaptureGroup
        luminanceAdjustment.backdropView.groupName = backgroundCaptureGroup
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        if pocketMaskedBlur.superview != nil {
            pocketMaskedBlur.frame = bounds
        }
        luminanceAdjustment.frame = bounds
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

        let edge: RectEdge
        
        init(edge: RectEdge) {
            self.edge = edge
            super.init(frame: .zero)

            tracksLuma = true
            tracksLumaWhileHidden = true
            if #available(iOS 26.0, macOS 26.0, *) {
                allowsFilteredLuma = true
                lumaUpdateRate = 0.25
            }
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let bounds = self.bounds
            let shadowGenerator = ShadowGenerator(
                edge: edge,
                length: bounds.height,
                scaleFactor: screenScaleFactor
            )
            
            updatePocketBlurFilter(shadowImage: shadowGenerator.renderShadowImage())
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

    private final class LuminanceAdjustment: PocketElementView {

        let backdropView: BackdropView = .init()
        let shadowView: ShadowView

        init(edge: RectEdge) {
            shadowView = .init(edge: edge)
            super.init(frame: .zero)

            #if canImport(UIKit)
            self.isUserInteractionEnabled = false
            backdropView.alpha = 0.85
            #elseif canImport(AppKit)
            ensureLayer.allowsGroupBlending = true
            #endif

            backdropView.scale = 0.5
            if #available(iOS 26.0, macOS 26.0, *) {
                backdropView.allowsFilteredLuma = true
            }
            addSubview(backdropView)

            let shadowViewLayer = shadowView.ensureLayer
            shadowViewLayer.allowsGroupBlending = true
            shadowViewLayer.compositingFilter = "destIn" as NSString
            addSubview(shadowView)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let bounds = self.bounds
            backdropView.frame = bounds
            shadowView.frame = bounds
        }
    }
}

extension ScrollPocket {
    
    private final class ShadowView: PocketElementView {
        
        let edge: RectEdge
        
        let shadowLayer: CALayer = .init()
        
        init(edge: RectEdge) {
            self.edge = edge
            super.init(frame: .zero)
            ensureLayer.addSublayer(shadowLayer)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let bounds = self.bounds
            let shadowGenerator = ShadowGenerator(
                edge: edge,
                length: bounds.height,
                scaleFactor: screenScaleFactor
            )
            
            shadowLayer.frame = bounds
            shadowLayer.contents = shadowGenerator.renderShadowImage()
        }
    }
}
