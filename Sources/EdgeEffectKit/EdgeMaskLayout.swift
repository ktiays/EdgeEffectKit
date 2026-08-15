//
//  Created by ktiays on 2026/5/18.
//  Copyright (c) 2026 ktiays. All rights reserved.
//

import CoreGraphics

/// Resolved geometry for one edge's mask, measured relative to a baseline at the end of `extent`.
struct EdgeMaskLayout {

    /// The mask length measured from the baseline toward the edge.
    let aboveBaseline: CGFloat

    /// The mask length measured from the baseline away from the edge.
    let belowBaseline: CGFloat

    /// The combined length the mask occupies along the edge's axis.
    var proposedLength: CGFloat { aboveBaseline + belowBaseline }

    /// The length of the region rendered entirely in the final mask state.
    let solidLength: CGFloat

    /// The length of the region over which the mask blends between its final state and no effect.
    ///
    /// This is `configuration.transitionLength`. A value of `0` produces a hard cut.
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
