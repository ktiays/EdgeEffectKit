//
//  Created by Cyandev on 2026/5/18.
//  Copyright (c) 2026 Cyandev. All rights reserved.
// 

import CoreGraphics

struct PocketMaskGenerator {
    
    var edge: RectEdge {
        didSet {
            guard edge != oldValue else {
                return
            }
            invalidateImageCache()
        }
    }
    
    var solidLength: CGFloat {
        didSet {
            guard solidLength != oldValue else {
                return
            }
            invalidateImageCache()
        }
    }
    
    var blendingLength: CGFloat {
        didSet {
            guard blendingLength != oldValue else {
                return
            }
            invalidateImageCache()
        }
    }
    
    var scaleFactor: CGFloat {
        didSet {
            guard scaleFactor != oldValue else {
                return
            }
            invalidateImageCache()
        }
    }
    
    private var imageCache: CGImage?
    
    init(edge: RectEdge) {
        self.edge = edge
        self.solidLength = 0
        self.blendingLength = 0
        self.scaleFactor = 1.0
        self.imageCache = nil
    }
    
    private mutating func invalidateImageCache() {
        imageCache = nil
    }
    
    func renderShadowImage() -> CGImage? {
        if let imageCache {
            return imageCache
        }
        
        let edge = self.edge
        let solidPixelCount = Int(ceil(solidLength * scaleFactor))
        let blendingPixelCount = Int(ceil(blendingLength * scaleFactor))
        let pixelCount = solidPixelCount + blendingPixelCount
        
        let imageSize = if edge == .left || edge == .right {
            (pixelCount, 1)
        } else {
            (1, pixelCount)
        }
        
        let bytesPerRow = imageSize.0 * 4
        let byteCount = bytesPerRow * imageSize.1
        var pixelData = [UInt8](unsafeUninitializedCapacity: byteCount) { buffer, initializedCount in
            Self.renderShadow(
                in: buffer,
                solidPixelCount: solidPixelCount,
                blendingPixelCount: blendingPixelCount,
                edge: edge
            )
            initializedCount = byteCount
        }
        
        return pixelData.withUnsafeMutableBytes { pixelDataPointer in
            let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
                | CGBitmapInfo.byteOrder32Big.rawValue
            let ctx = CGContext(
                data: .init(pixelDataPointer.baseAddress),
                width: imageSize.0,
                height: imageSize.1,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: bitmapInfo
            )
            return ctx?.makeImage()
        }
    }
    
    private static let SIGMA: CGFloat = 2.5
    
    private static func standardNormalCDF(_ value: CGFloat) -> CGFloat {
        return 0.5 * (1.0 + erf(value / sqrt(2.0)))
    }
    
    static private func renderShadow(
        in pixelBuffer: UnsafeMutableBufferPointer<UInt8>,
        solidPixelCount: Int,
        blendingPixelCount: Int,
        edge: RectEdge
    ) {
        func transitionAlpha(_ t: CGFloat) -> CGFloat {
            let boundedT = clamp(t, min: 0.0, max: 1.0)
            let z = -SIGMA + ((SIGMA * 2.0) * boundedT)
            let sigmaCDF = standardNormalCDF(SIGMA)
            let denominator = sigmaCDF - standardNormalCDF(-SIGMA)
            let value = (sigmaCDF - standardNormalCDF(z)) / denominator
            return 1.0 - clamp(value, min: 0.0, max: 1.0)
        }
        
        let isReversed = edge == .right || edge == .bottom
        
        let calculateT = isReversed ? { (pixel: Int) in
            return CGFloat(pixel) / CGFloat(blendingPixelCount)
        } : { (pixel: Int) in
            return 1.0 - (CGFloat(pixel) / CGFloat(blendingPixelCount))
        }
        
        var offset = 0
        
        let fillSolid = {
            for _ in 0..<solidPixelCount {
                pixelBuffer[offset] = 0
                pixelBuffer[offset + 1] = 0
                pixelBuffer[offset + 2] = 0
                pixelBuffer[offset + 3] = 255
                offset += 4
            }
        }
        
        if !isReversed {
            fillSolid()
        }
        
        for i in 0..<blendingPixelCount {
            pixelBuffer[offset] = 0
            pixelBuffer[offset + 1] = 0
            pixelBuffer[offset + 2] = 0
            pixelBuffer[offset + 3] = UInt8(transitionAlpha(calculateT(i)) * 255.0)
            offset += 4
        }
        
        if isReversed {
            fillSolid()
        }
    }
}
