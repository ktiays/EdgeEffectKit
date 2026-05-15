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
    private let pocketMask: PocketMask
    private let pocketMaskedBlur: PocketBlur
    private lazy var luminanceAdjustment: LuminanceAdjustment = .init(mask: pocketMask)

    public let backgroundCapture: BackdropView = .init()

    open var maskLength: CGFloat {
        get { pocketMask.length }
        set { pocketMask.length = newValue }
    }

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
        self.pocketMask = .init(edge: edge)
        if #available(iOS 26.0, macOS 26.0, *) {
            pocketMaskedBlur = .init(mask: pocketMask)
        } else {
            pocketMaskedBlur = .init(mask: nil)
        }
        super.init(frame: .zero)

        addSubviewToEdge(pocketMask)

        if #available(iOS 26.0, macOS 26.0, *) {
            updatePocketBlurFilter()
        }
        pocketMaskedBlur.tracksLuma = true
        pocketMaskedBlur.tracksLumaWhileHidden = true
        if #available(iOS 26.0, macOS 26.0, *) {
            pocketMaskedBlur.allowsFilteredLuma = true
            pocketMaskedBlur.lumaUpdateRate = 0.25
        }
        pocketMask.pocketBlur = pocketMaskedBlur
        updatePocketBlur()

        addSubviewToEdge(luminanceAdjustment)

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

        pocketMask.registerShadowImageDidRender { [weak self] image in
            self?.updatePocketBlurFilter(shadowImage: image)
        }
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviewToEdge(_ subview: PlatformView) {
        addSubview(subview)
        activateConstraintToEdge(for: subview)
    }

    private func activateConstraintToEdge(for view: PlatformView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func updatePocketBlur() {
        if isBlurEnabled {
            pocketMask.shadowRadius = 18
            if pocketMaskedBlur.superview == nil {
                #if canImport(AppKit)
                addSubview(pocketMaskedBlur, positioned: .above, relativeTo: pocketMask)
                #elseif canImport(UIKit)
                insertSubview(pocketMaskedBlur, aboveSubview: pocketMask)
                #else
                #error("Unsupported platform")
                #endif
                activateConstraintToEdge(for: pocketMaskedBlur)
            }
        } else {
            pocketMask.shadowRadius = 24
            pocketMaskedBlur.removeFromSuperview()
        }
    }

    private func updatePocketBlurFilter(shadowImage: PlatformImage? = nil) {
        let variableBlur = QuartzFilter.variableBlur()
        variableBlur.radius = 1
        variableBlur.dither = false
        variableBlur.normalizeEdges = true
        if #available(iOS 26.0, macOS 26.0, *) {
            let sourceLayer = pocketMaskedBlur.portalView.portalLayer
            variableBlur.fade = true

            let sourceLayerName = "\(ObjectIdentifier(sourceLayer))"
            sourceLayer.name = sourceLayerName
            variableBlur.sourceSublayerName = sourceLayerName
        } else if let cgImage = shadowImage?.edgeEffectCGImage {
            variableBlur.maskImage = cgImage
        } else {
            pocketMaskedBlur.ensureLayer.quartzFilters = []
            return
        }
        pocketMaskedBlur.ensureLayer.quartzFilters = [variableBlur]
    }
}

extension ScrollPocket {

    private final class PocketMask: PocketElementView {

        private let edge: RectEdge
        private let container: PocketElementView = .init()
        private let shadowLayer: CALayer = .init()

        weak var pocketBlur: PocketBlur?

        private(set) var shadowImage: PlatformImage?
        private var shadowImageRenderCallbacks: [(PlatformImage) -> Void] = []
        private lazy var shadowImageRenderQueue: DispatchQueue = .global(qos: .userInteractive)

        var shadowRadius: CGFloat {
            get { shadowLayer.shadowRadius }
            set { shadowLayer.shadowRadius = newValue }
        }

        var length: CGFloat = 0 {
            didSet {
                setNeedsLayout()
            }
        }

        init(edge: RectEdge) {
            self.edge = edge
            super.init(frame: .zero)

            #if canImport(UIKit)
            self.isUserInteractionEnabled = false
            #endif
            addSubview(container)

            shadowLayer.shadowPathIsBounds = true
            shadowLayer.shadowColor = PlatformColor.black.cgColor
            shadowLayer.shadowOpacity = 1
            shadowLayer.allowsGroupOpacity = true
            container.ensureLayer.addSublayer(shadowLayer)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        #if canImport(UIKit)
        override func layoutSubviews() {
            super.layoutSubviews()
            
            performLayout()
        }
        #elseif canImport(AppKit)
        override func layout() {
            super.layout()
            
            performLayout()
        }
        #else
        #error("Unsupported platform")
        #endif
        
        private func performLayout() {
            container.frame = bounds
            let overflowMargin: CGFloat = 26
            let edgeInset: CGFloat = 10

            switch edge {
            case .top:
                let shadowHeight = length - edgeInset + overflowMargin
                shadowLayer.bounds = .init(
                    origin: .zero,
                    size: .init(
                        width: bounds.width + overflowMargin * 2,
                        height: shadowHeight
                    )
                )
                shadowLayer.position = .init(
                    x: bounds.width / 2,
                    y: length - edgeInset - shadowHeight / 2
                )
            case .left:
                let shadowWidth = length - edgeInset + overflowMargin
                shadowLayer.bounds = .init(
                    origin: .zero,
                    size: .init(
                        width: shadowWidth,
                        height: bounds.height + overflowMargin * 2
                    )
                )
                shadowLayer.position = .init(
                    x: length - edgeInset - shadowWidth / 2,
                    y: bounds.height / 2
                )
            case .right:
                let shadowWidth = length - edgeInset + overflowMargin
                shadowLayer.bounds = .init(
                    origin: .zero,
                    size: .init(
                        width: shadowWidth,
                        height: bounds.height + overflowMargin * 2
                    )
                )
                shadowLayer.position = .init(
                    x: bounds.width - (length - edgeInset - shadowWidth / 2),
                    y: bounds.height / 2
                )
            case .bottom:
                let shadowHeight = length - edgeInset + overflowMargin
                shadowLayer.bounds = .init(
                    origin: .zero,
                    size: .init(
                        width: bounds.width + overflowMargin * 2,
                        height: shadowHeight
                    )
                )
                shadowLayer.position = .init(
                    x: bounds.width / 2,
                    y: bounds.height - (length - edgeInset - shadowHeight / 2)
                )
            }

            if #available(iOS 26.0, macOS 26.0, *) {
                pocketBlur?.lumaSubrect = bounds.intersection(shadowLayer.frame)
            } else {
                let shadowImageSize = shadowImage?.size ?? .zero
                if shadowImageSize != bounds.size {
                    renderShadowImage()
                }
            }
        }

        private func renderShadowImage() {
            let bounds = self.bounds
            let viewSize = bounds.size
            guard viewSize.width > 0, viewSize.height > 0 else { return }

            let shadowRect = shadowLayer.frame
            guard !shadowRect.isEmpty else {
                return
            }

            let shadowRadius = self.shadowRadius
            let maskColorMatrix = PocketBlur.maskColorMatrix
            shadowImageRenderQueue.async { [weak self] in
                let blankImage = CIImage(color: .clear).cropped(to: bounds)
                let blackRectangle = CIImage(color: CIColor.black).cropped(to: shadowRect)
                let sourceImage = blackRectangle.composited(over: blankImage)
                let blurredImage = sourceImage.applyingGaussianBlur(sigma: shadowRadius)
                let croppedImage = blurredImage.cropped(to: bounds)

                let colorMatrixFilter = CIFilter.colorMatrix()
                let matrix = maskColorMatrix
                colorMatrixFilter.setValue(croppedImage, forKey: kCIInputImageKey)
                colorMatrixFilter.setValue(matrix.rVector, forKey: "inputRVector")
                colorMatrixFilter.setValue(matrix.gVector, forKey: "inputGVector")
                colorMatrixFilter.setValue(matrix.bVector, forKey: "inputBVector")
                colorMatrixFilter.setValue(matrix.aVector, forKey: "inputAVector")
                colorMatrixFilter.setValue(matrix.biasVector, forKey: "inputBiasVector")

                guard let finalImage = colorMatrixFilter.outputImage else {
                    return
                }

                let transform = CGAffineTransform(scaleX: 1, y: -1)
                    .translatedBy(x: 0, y: -croppedImage.extent.height)
                let context = CIContext(options: [.useSoftwareRenderer: false])
                guard let cgImage = context.createCGImage(finalImage.transformed(by: transform), from: croppedImage.extent) else {
                    return
                }

                DispatchQueue.main.async {
                    let shadowImage = PlatformImage(edgeEffectCGImage: cgImage, size: viewSize)
                    self?.shadowImageRenderCallbacks.forEach { callback in
                        callback(shadowImage)
                    }
                    self?.shadowImage = shadowImage
                }
            }
        }

        func registerShadowImageDidRender(_ renderCallback: @escaping (PlatformImage) -> Void) {
            shadowImageRenderCallbacks.append(renderCallback)
            if let shadowImage {
                renderCallback(shadowImage)
            }
        }
    }
}

extension ScrollPocket {

    private final class PocketBlur: BackdropView {

        let portalView: PortalView

        // swift-format-ignore
        static let maskColorMatrix: ColorMatrix = .init(
            m11: 1.0, m12: 0.0, m13: 0.0, m14: 0.0, m15: 0.0,
            m21: 0.0, m22: 1.0, m23: 0.0, m24: 0.0, m25: 0.0,
            m31: 0.0, m32: 0.0, m33: 1.0, m34: 0.0, m35: 0.0,
            m41: 0.0, m42: 0.0, m43: 0.0, m44: 1.25, m45: -0.25
        )

        init(mask: PocketMask?) {
            portalView = .init(sourceView: mask)
            super.init(frame: .zero)

            #if canImport(UIKit)
            self.isUserInteractionEnabled = false
            #endif
            self.tracksLuma = true
            self.tracksLumaWhileHidden = true
            self.scale = 0.5

            if #available(iOS 26.0, macOS 26.0, *) {
                self.allowsFilteredLuma = true
            }

            if mask != nil {
                portalView.matchesTransform = true
                portalView.matchesPosition = true
                portalView.hidesSourceView = true
                #if canImport(UIKit)
                portalView.allowsHitTesting = false
                #endif
                portalView.portalLayer.rasterizationScale = 0.25
                portalView.portalLayer.shouldRasterize = true
                let colorMatrixFilter = QuartzFilter.colorMatrix()
                colorMatrixFilter.colorMatrix = Self.maskColorMatrix
                portalView.portalLayer.quartzFilters = [colorMatrixFilter]

                addSubview(portalView)
                portalView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    portalView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    portalView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    portalView.topAnchor.constraint(equalTo: topAnchor),
                    portalView.bottomAnchor.constraint(equalTo: bottomAnchor),
                ])
            }
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension ScrollPocket {

    private final class LuminanceAdjustment: PocketElementView {

        fileprivate let backdropView: BackdropView = .init()
        private let portalView: PortalView

        init(mask: PocketMask) {
            self.portalView = .init(sourceView: mask)
            super.init(frame: .zero)

            #if canImport(UIKit)
            self.isUserInteractionEnabled = false
            backdropView.alpha = 0.85
            #elseif canImport(AppKit)
            ensureLayer.allowsGroupBlending = true
//            backdropView.ensureLayer.opacity = 0.85
            #endif

//            backdropView.scale = 0.5
            if #available(iOS 26.0, macOS 26.0, *) {
                backdropView.allowsFilteredLuma = true
            }
            addSubview(backdropView)
            backdropView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                backdropView.leadingAnchor.constraint(equalTo: leadingAnchor),
                backdropView.trailingAnchor.constraint(equalTo: trailingAnchor),
                backdropView.topAnchor.constraint(equalTo: topAnchor),
                backdropView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])

            portalView.portalLayer.compositingFilter = "destIn" as NSString
            portalView.portalLayer.allowsGroupBlending = true
//            portalView.portalLayer.rasterizationScale = 0.25
            portalView.portalLayer.shouldRasterize = true
            portalView.matchesPosition = true
            portalView.matchesTransform = true
            portalView.hidesSourceView = true
            portalView.allowsBackdropGroups = true
            #if canImport(UIKit)
            portalView.allowsHitTesting = false
            #endif
            addSubview(portalView)
            portalView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                portalView.leadingAnchor.constraint(equalTo: leadingAnchor),
                portalView.trailingAnchor.constraint(equalTo: trailingAnchor),
                portalView.topAnchor.constraint(equalTo: topAnchor),
                portalView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension PlatformImage {

    fileprivate convenience init(edgeEffectCGImage cgImage: CGImage, size: CGSize) {
        #if canImport(UIKit)
        self.init(cgImage: cgImage, scale: 1.0, orientation: .up)
        #elseif canImport(AppKit)
        self.init(cgImage: cgImage, size: size)
        #else
        #error("Unsupported platform")
        #endif
    }

    fileprivate var edgeEffectCGImage: CGImage? {
        #if canImport(UIKit)
        cgImage
        #elseif canImport(AppKit)
        var proposedRect = CGRect(origin: .zero, size: size)
        return cgImage(forProposedRect: &proposedRect, context: nil, hints: nil)
        #else
        #error("Unsupported platform")
        #endif
    }
}
