//
//  Created by ktiays on 2026/5/22.
//  Copyright (c) 2026 ktiays. All rights reserved.
//

import Foundation

/// Constrains a value to lie within a specified range.
///
/// Use this function to ensure that a value doesn't exceed the bounds of a range.
///
/// - Parameters:
///   - value: The input value to constrain.
///   - min: The lower end of the range to constrain `value` to.
///   - max: The upper end of the range to constrain `value` to.
/// - Returns: The value constrained between `min` and `max`.
@inlinable
func clamp<T>(_ value: T, min: T, max: T) -> T where T: Comparable {
    Swift.min(Swift.max(value, min), max)
}

@inlinable
func standardNormalCDF<T>(_ value: T) -> T where T: BinaryFloatingPoint {
    return T(0.5 * (1.0 + erf(Double(value) / sqrt(2.0))))
}
