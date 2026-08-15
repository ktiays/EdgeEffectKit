import CoreGraphics
import Testing
@testable import EdgeEffectKit

@Suite("EdgeMaskLayout")
struct EdgeMaskLayoutTests {

    @Test("transitionLength 0 is a hard cut covering only extent")
    func zeroTransitionIsHardCut() {
        let layout = EdgeMaskLayout(
            .init(extent: 59, transitionLength: 0, maskPlacement: .visuallyAlignedToExtentEnd)
        )

        #expect(layout.blendingLength == 0)
        #expect(layout.solidLength == 59)
        #expect(layout.belowBaseline == 0)
        #expect(layout.aboveBaseline == 59)
        #expect(layout.proposedLength == 59)
    }

    @Test("alignedToExtentEnd keeps the blend inside extent")
    func alignedToExtentEnd() {
        let layout = EdgeMaskLayout(
            .init(extent: 100, transitionLength: 40, maskPlacement: .alignedToExtentEnd)
        )

        #expect(layout.blendingLength == 40)
        #expect(layout.solidLength == 60)
        #expect(layout.belowBaseline == 0)
        #expect(layout.proposedLength == 100)
    }

    @Test("visuallyAlignedToExtentEnd extends the blend past extent")
    func visuallyAlignedToExtentEnd() {
        let layout = EdgeMaskLayout(
            .init(extent: 100, transitionLength: 40, maskPlacement: .visuallyAlignedToExtentEnd)
        )

        #expect(layout.blendingLength == 40)
        #expect(layout.solidLength == 100 - 40 * 0.51)
        #expect(layout.belowBaseline == 40 * 0.49)
        #expect(layout.proposedLength == 100 + 40 * 0.49)
    }

    @Test("afterExtent keeps extent solid and places the blend beyond it")
    func afterExtent() {
        let layout = EdgeMaskLayout(
            .init(extent: 100, transitionLength: 40, maskPlacement: .afterExtent)
        )

        #expect(layout.blendingLength == 40)
        #expect(layout.solidLength == 100)
        #expect(layout.belowBaseline == 40)
        #expect(layout.proposedLength == 140)
    }

    @Test("mask image length matches the laid-out pocket")
    func maskLengthMatchesPocket() {
        let placements: [EdgeEffectConfiguration.EdgeMaskPlacement] = [
            .alignedToExtentEnd,
            .visuallyAlignedToExtentEnd,
            .afterExtent,
        ]
        for placement in placements {
            for (extent, transition) in [(100.0, 40.0), (20.0, 40.0), (59.0, 0.0)] {
                let layout = EdgeMaskLayout(
                    .init(extent: extent, transitionLength: transition, maskPlacement: placement)
                )
                #expect(layout.solidLength + layout.blendingLength == layout.proposedLength)
            }
        }
    }
}
