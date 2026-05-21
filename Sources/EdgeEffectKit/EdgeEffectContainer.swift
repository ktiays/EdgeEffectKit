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
    
    /// A Boolean value that indicates whether the edge effect includes variable blur.
    public var isBlurEnabled: Bool
    
    /// The length, in points, over which the edge effect is rendered.
    public var maskLength: CGFloat
    
    /// Creates an edge effect configuration.
    ///
    /// - Parameters:
    ///   - isBlurEnabled: A Boolean value that indicates whether the edge effect includes variable blur.
    ///   - maskLength: The length, in points, over which the edge effect is rendered.
    public init(isBlurEnabled: Bool = true, maskLength: CGFloat = 12) {
        self.isBlurEnabled = isBlurEnabled
        self.maskLength = maskLength
    }
}

/// A view that renders configurable visual effects along the edges of its content.
@objc(EEKEdgeEffectContainer)
open class EdgeEffectContainer: _InternalBaseView {
    
    /// Configuration values that control which edges render effects and how their background is sampled.
    public struct Configuration: Hashable, Sendable {
        
        /// The color to replay behind edge effects instead of capturing the container background.
        public var replayBackgroundColor: PlatformColor?
        
        public var top: EdgeEffectConfiguration?
        
        public var left: EdgeEffectConfiguration?
        
        public var right: EdgeEffectConfiguration?
        
        public var bottom: EdgeEffectConfiguration?
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
            updatePockets()
            updateBackgroundCaptures()
            setNeedsLayout()
        }
    }
    
    private var scrollPockets: [RectEdge: ScrollPocket] = [:]
    
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
                assert(configuration.top != nil)
                let topMaskLength = configuration.top?.maskLength ?? 0
                pocket.frame = .init(x: 0, y: 0, width: bounds.width, height: topMaskLength)
            case .left:
                assert(configuration.left != nil)
                let leftMaskLength = configuration.left?.maskLength ?? 0
                pocket.frame = .init(x: 0, y: 0, width: leftMaskLength, height: bounds.height)
            case .bottom:
                assert(configuration.bottom != nil)
                let bottomMaskLength = configuration.bottom?.maskLength ?? 0
                pocket.frame = .init(x: 0, y: bounds.height - bottomMaskLength, width: bounds.width, height: bottomMaskLength)
            case .right:
                assert(configuration.right != nil)
                let rightMaskLength = configuration.right?.maskLength ?? 0
                pocket.frame = .init(x: bounds.width - rightMaskLength, y: 0, width: rightMaskLength, height: bounds.height)
            }
        }
    }
    
    private func makeViewConstraintsToEdge(_ view: PlatformView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
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
                makeViewConstraintsToEdge(pocketBackgroundCapture)
            }
        }
    }
    
    /// Creates, reuses, or removes pocket views to match the enabled edges in `configuration`.
    private func updatePockets() {
        func update(for edge: RectEdge, configuration: EdgeEffectConfiguration?) {
            guard let configuration else {
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
        }
        update(for: .top, configuration: configuration.top)
        update(for: .left, configuration: configuration.left)
        update(for: .right, configuration: configuration.right)
        update(for: .bottom, configuration: configuration.bottom)
    }
}
