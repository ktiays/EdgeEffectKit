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
    
    var length: CGFloat {
        didSet {
            guard length != oldValue else {
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
    
    init(edge: RectEdge, length: CGFloat = 0, scaleFactor: CGFloat = 1.0) {
        self.edge = edge
        self.length = length
        self.scaleFactor = scaleFactor
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
        let lengthInPixel = Int(ceil(length * scaleFactor))
        
        let imageSize = if edge == .left || edge == .right {
            (lengthInPixel, 1)
        } else {
            (1, lengthInPixel)
        }
        
        let bytesPerRow = imageSize.0 * 4
        let byteCount = bytesPerRow * imageSize.1
        var pixelData = [UInt8](unsafeUninitializedCapacity: byteCount) { buffer, initializedCount in
            Self.renderShadow(in: buffer, pixelCount: imageSize.0 * imageSize.1, edge: edge)
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
    
    static private func renderShadow(
        in pixelBuffer: UnsafeMutableBufferPointer<UInt8>,
        pixelCount: Int,
        edge: RectEdge
    ) {
        func smoothStep(_ t: CGFloat) -> CGFloat {
            let t2 = t * t
            let t3 = t2 * t
            return 3 * t2 - 2 * t3
        }
        
        let calculateAlpha = if edge == .left || edge == .top {
            { (pixel: Int) in
                let t = 1.0 - (CGFloat(pixel) / CGFloat(pixelCount))
                return UInt8(smoothStep(t) * 255.0)
            }
        } else {
            { (pixel: Int) in
                let t = CGFloat(pixel) / CGFloat(pixelCount)
                return UInt8(smoothStep(t) * 255.0)
            }
        }
        
        for i in 0..<pixelCount {
            let offset = i * 4
            pixelBuffer[offset] = 0
            pixelBuffer[offset + 1] = 0
            pixelBuffer[offset + 2] = 0
            pixelBuffer[offset + 3] = calculateAlpha(i)
        }
    }
}
