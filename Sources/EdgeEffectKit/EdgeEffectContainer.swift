//
//  Created by ktiays on 2026/5/18.
//  Copyright (c) 2026 ktiays. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#else
#error("Unsupported platform")
#endif

/// Configuration values for an effect rendered along one edge.
public struct EdgeEffectConfiguration: Sendable, Hashable {
    
    /// Constants that indicate where the transition region is placed relative to `extent`.
    public enum EdgeMaskPlacement: Sendable, Hashable {

        /// Aligns the end of the transition region exactly with `extent`.
        case alignedToExtentEnd

        /// Aligns the transition region with `extent` as it appears to the eye, allowing the region to
        /// extend past `extent` to compensate for the non-linear transition curve.
        case visuallyAlignedToExtentEnd

        /// Places the transition region beyond `extent`, leaving the entire extent in the final mask state.
        case afterExtent
    }
    
    /// A Boolean value that indicates whether the edge effect includes variable blur.
    public var isBlurEnabled: Bool
    
    /// The total distance from the edge that the effect conceptually covers.
    public var extent: CGFloat
    
    /// The length of the region over which the effect transitions between its final state and no effect.
    public var transitionLength: CGFloat
    
    /// A value that determines where the transition region is positioned relative to `extent`.
    public var maskPlacement: EdgeMaskPlacement
    
    /// Creates a configuration for an edge effect.
    ///
    /// - Parameters:
    ///   - extent: The total distance from the edge that the effect conceptually covers.
    ///   - transitionLength: The length of the region over which the effect transitions between its final state and no effect.
    ///   - isBlurEnabled: A Boolean value that indicates whether the effect includes variable blur.
    ///   - maskPlacement: A value that determines where the transition region is positioned relative to `extent`.
    public init(
        extent: CGFloat,
        transitionLength: CGFloat = 12,
        isBlurEnabled: Bool = true,
        maskPlacement: EdgeMaskPlacement = .visuallyAlignedToExtentEnd
    ) {
        self.extent = extent
        self.transitionLength = transitionLength
        self.isBlurEnabled = isBlurEnabled
        self.maskPlacement = maskPlacement
    }
}

/// A view that renders configurable visual effects along the edges of its content.
@objc(EEKEdgeEffectContainer)
open class EdgeEffectContainer: _InternalBaseView {
    
    /// Configuration values that control which edges render effects and how their background is sampled.
    public struct Configuration: Hashable, Sendable {
        
        /// The color to replay behind edge effects instead of capturing the container background.
        public var replayBackgroundColor: PlatformColor?
        
        /// The configuration for the top edge effect, or `nil` to disable it.
        public var top: EdgeEffectConfiguration?
        
        /// The configuration for the left edge effect, or `nil` to disable it.
        public var left: EdgeEffectConfiguration?
        
        /// The configuration for the right edge effect, or `nil` to disable it.
        public var right: EdgeEffectConfiguration?
        
        /// The configuration for the bottom edge effect, or `nil` to disable it.
        public var bottom: EdgeEffectConfiguration?
    }
    
    /// Resolved geometry for one edge's mask, measured relative to a baseline at the end of `extent`.
    private struct EdgeMaskLayout {
        
        /// The mask length measured from the baseline toward the edge.
        let aboveBaseline: CGFloat
        
        /// The mask length measured from the baseline away from the edge.
        let belowBaseline: CGFloat
        
        /// The combined length the mask occupies along the edge's axis.
        var proposedLength: CGFloat { aboveBaseline + belowBaseline }
        
        /// The length of the region rendered entirely in the final mask state.
        let solidLength: CGFloat
        
        /// The length of the region over which the mask blends between its final state and no effect.
        let blendingLength: CGFloat
        
        /// Derives the layout from `configuration`, anchoring the blending region according to its `maskPlacement`.
        init(_ configuration: EdgeEffectConfiguration) {
            let baselineAnchor: CGFloat =
                switch configuration.maskPlacement {
                case .alignedToExtentEnd:
                    0.0
                case .visuallyAlignedToExtentEnd:
                    0.49
                case .afterExtent:
                    1.0
                }
            belowBaseline = configuration.transitionLength * baselineAnchor
            aboveBaseline = max(configuration.extent, configuration.transitionLength * (1.0 - baselineAnchor))
            blendingLength = configuration.transitionLength
            solidLength = max(0, configuration.extent - configuration.transitionLength * (1.0 - baselineAnchor))
        }
    }
    
    /// The view displayed below the configured edge effects.
    open var contentView: PlatformView? {
        didSet {
            guard contentView !== oldValue else {
                return
            }
            if let contentView {
                contentContainer.addSubview(contentView)
                makeViewConstraintsToEdge(contentView)
            } else {
                contentContainer.removeFromSuperview()
            }
        }
    }
    
    /// The active edge effect configuration for the container.
    open var configuration: EdgeEffectContainer.Configuration = .init() {
        didSet {
            guard configuration != oldValue else {
                return
            }
            updateMaskLayouts()
            updatePockets()
            updateBackgroundCaptures()
            setNeedsLayout()
        }
    }
    
    /// The active pocket views that render each enabled edge effect, keyed by edge.
    private var scrollPockets: [RectEdge: ScrollPocket] = [:]

    /// Cached layout metrics for each enabled edge configuration.
    private var maskLayouts: [EdgeEffectConfiguration: EdgeMaskLayout] = [:]
    
    /// The container that hosts `contentView` beneath the edge effect pockets.
    private let contentContainer: _InternalBaseView = .init()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureSubviews()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureSubviews()
    }
    
    private func configureSubviews() {
        addSubview(contentContainer)
        makeViewConstraintsToEdge(contentContainer)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        contentContainer.frame = bounds
        for (edge, pocket) in scrollPockets {
            switch edge {
            case .top:
                guard let conf = configuration.top, let layout = maskLayouts[conf] else {
                    assertionFailure()
                    continue
                }
                pocket.frame = .init(x: 0, y: conf.extent - layout.aboveBaseline, width: bounds.width, height: layout.proposedLength)
            case .left:
                guard let conf = configuration.left, let layout = maskLayouts[conf] else {
                    assertionFailure()
                    continue
                }
                pocket.frame = .init(x: conf.extent - layout.aboveBaseline, y: 0, width: layout.proposedLength, height: bounds.height)
            case .bottom:
                guard let conf = configuration.bottom, let layout = maskLayouts[conf] else {
                    assertionFailure()
                    continue
                }
                pocket.frame = .init(x: 0, y: bounds.height - conf.extent - layout.belowBaseline, width: bounds.width, height: layout.proposedLength)
            case .right:
                guard let conf = configuration.right, let layout = maskLayouts[conf] else {
                    assertionFailure()
                    continue
                }
                pocket.frame = .init(x: bounds.width - conf.extent - layout.belowBaseline, y: 0, width: layout.proposedLength, height: bounds.height)
            }
        }
    }
    
    /// Pins every edge of `view` to `container`, or to the receiver when `container` is `nil`.
    private func makeViewConstraintsToEdge(_ view: PlatformView, relativeTo container: PlatformView? = nil) {
        let container = container ?? self
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
    }
    
    /// Rebuilds the cached layout metrics for the currently enabled edges.
    private func updateMaskLayouts() {
        maskLayouts.removeAll()
        if let conf = configuration.top {
            maskLayouts[conf] = .init(conf)
        }
        if let conf = configuration.left {
            maskLayouts[conf] = .init(conf)
        }
        if let conf = configuration.bottom {
            maskLayouts[conf] = .init(conf)
        }
        if let conf = configuration.right {
            maskLayouts[conf] = .init(conf)
        }
    }
    
    /// Synchronizes each pocket's background source with `configuration`.
    private func updateBackgroundCaptures() {
        let replayBackgroundColor = configuration.replayBackgroundColor
        for pocket in scrollPockets.values {
            pocket.replayBackgroundColor = replayBackgroundColor
            
            let pocketBackgroundCapture = pocket.backgroundCapture
            if replayBackgroundColor != nil {
                pocketBackgroundCapture.removeFromSuperview()
            } else if pocketBackgroundCapture.superview != self {
                insertSubview(pocketBackgroundCapture, belowSubview: contentContainer)
                makeViewConstraintsToEdge(pocketBackgroundCapture, relativeTo: pocket)
            }
        }
    }
    
    /// Creates, reuses, or removes pocket views to match the enabled edges in `configuration`.
    private func updatePockets() {
        func update(for edge: RectEdge, configuration: EdgeEffectConfiguration?) {
            guard let configuration, let layout = maskLayouts[configuration] else {
                scrollPockets.removeValue(forKey: edge)
                return
            }
            
            let pocket: ScrollPocket =
                if let existing = scrollPockets[edge] {
                    existing
                } else {
                    {
                        let newPocket = ScrollPocket(edge: edge)
                        scrollPockets[edge] = newPocket
                        insertSubview(newPocket, aboveSubview: contentContainer)
                        return newPocket
                    }()
                }
            pocket.isBlurEnabled = configuration.isBlurEnabled
            pocket.solidLength = layout.solidLength
            pocket.blendingLength = layout.blendingLength
        }
        update(for: .top, configuration: configuration.top)
        update(for: .left, configuration: configuration.left)
        update(for: .right, configuration: configuration.right)
        update(for: .bottom, configuration: configuration.bottom)
    }
}
