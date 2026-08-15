import CoreGraphics
import Testing
@testable import EdgeEffectKit

@Suite("PocketMaskGenerator")
struct PocketMaskGeneratorTests {

    @Test("zero blending length renders an all-opaque hard cut")
    func zeroBlendingLengthIsHardCut() throws {
        var generator = PocketMaskGenerator(edge: .top)
        generator.solidLength = 10
        generator.blendingLength = 0
        generator.scaleFactor = 1

        let image = try #require(generator.renderShadowImage())
        #expect(image.width == 1)
        #expect(image.height == 10)

        let alphas = try alphas(in: image)
        #expect(alphas.allSatisfy { $0 == 255 })
    }

    @Test("a positive blending length produces a fade, not a hard cut")
    func positiveBlendingLengthFades() throws {
        var generator = PocketMaskGenerator(edge: .top)
        generator.solidLength = 4
        generator.blendingLength = 8
        generator.scaleFactor = 1

        let image = try #require(generator.renderShadowImage())
        let alphas = try alphas(in: image)

        #expect(alphas.prefix(4).allSatisfy { $0 == 255 })
        #expect(alphas.last! < 20)
        #expect(Set(alphas).count > 2)
    }

    @Test("empty lengths produce no image")
    func emptyLengthsProduceNoImage() {
        var generator = PocketMaskGenerator(edge: .top)
        generator.solidLength = 0
        generator.blendingLength = 0

        #expect(generator.renderShadowImage() == nil)
    }

    private func alphas(in image: CGImage) throws -> [UInt8] {
        let byteCount = image.bytesPerRow * image.height
        var pixels = [UInt8](repeating: 0, count: byteCount)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
            | CGBitmapInfo.byteOrder32Big.rawValue
        let context = try #require(
            CGContext(
                data: &pixels,
                width: image.width,
                height: image.height,
                bitsPerComponent: 8,
                bytesPerRow: image.bytesPerRow,
                space: colorSpace,
                bitmapInfo: bitmapInfo
            )
        )
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return stride(from: 3, to: byteCount, by: 4).map { pixels[$0] }
    }
}
