# EdgeEffectKit

Adaptive, blurred edge effects for scrollable content on iOS and macOS.

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2015%2B%20%7C%20macOS%2012%2B-blue.svg)
![SwiftPM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)
![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)

EdgeEffectKit renders configurable visual effects — a soft fade with an optional
variable blur — along the edges of scrollable content. A single
`EdgeEffectContainer` view wraps your existing content and applies independent,
per-edge treatments using backdrop capture and luminance-aware blending, so
scroll boundaries stay polished without rebuilding the effect stack in every
screen. It works with both UIKit and AppKit.

> [!IMPORTANT]
> EdgeEffectKit relies on private Core Animation and backdrop APIs, including
> `CABackdropLayer` and private `CALayer` properties. This makes it well suited
> to experimentation, prototypes, internal tools, and controlled distribution
> environments. Review your distribution requirements carefully before shipping
> it in App Store software.

## Features

- Soft edge fade with an optional masked variable blur, configured per edge.
- Independent top, left, right, and bottom edges — enable and tune each separately.
- Fine-grained control over extent, transition length, minimum opacity, and mask placement.
- Luminance-aware blending for smooth transitions over both light and dark content.
- Backdrop capture, or replay a solid background color instead of sampling the content.
- Cross-platform: UIKit (iOS 15+) and AppKit (macOS 12+), distributed via Swift Package Manager.

## Requirements

- Swift 6.0+
- iOS 15.0+
- macOS 12.0+
- Swift Package Manager

## Installation

Add EdgeEffectKit to your package dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/ktiays/EdgeEffectKit.git", branch: "main")
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "EdgeEffectKit", package: "EdgeEffectKit")
    ]
)
```

In Xcode, choose **File ▸ Add Package Dependencies…** and enter:

```text
https://github.com/ktiays/EdgeEffectKit.git
```

> Once a tagged release is published, pin to a version (for example,
> `.package(url: ..., from: "1.0.0")`) instead of tracking `main`.

## Usage

`EdgeEffectContainer` overlays the configured effects on top of its
`contentView`. Each edge is driven by an optional `EdgeEffectConfiguration`;
setting it to `nil` disables that edge.

Because `extent` is often tied to the safe area — which changes as the view lays
out — update `configuration` from your layout pass.

```swift
import UIKit
import EdgeEffectKit

final class ViewController: UIViewController {

    private let edgeEffect = EdgeEffectContainer()
    private let scrollView = UIScrollView()

    private var topConfiguration = EdgeEffectConfiguration(extent: 0)
    private var bottomConfiguration = EdgeEffectConfiguration(extent: 0, isBlurEnabled: false)

    override func viewDidLoad() {
        super.viewDidLoad()

        edgeEffect.contentView = scrollView
        view.addSubview(edgeEffect)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let insets = view.safeAreaInsets

        topConfiguration.extent = insets.top
        topConfiguration.transitionLength = 50
        bottomConfiguration.extent = insets.bottom
        bottomConfiguration.transitionLength = 32

        edgeEffect.configuration.top = topConfiguration
        edgeEffect.configuration.bottom = bottomConfiguration

        edgeEffect.frame = view.bounds
    }
}
```

On macOS the API is identical — wrap an `NSScrollView` and update
`configuration` from `viewWillLayout` in your `NSViewController`.

## Examples

The repository includes example apps for both platforms. Open
`Examples/EdgeEffectExamples.xcworkspace` to run them:

- `Examples/EdgeEffectExample` — iOS
- `Examples/EdgeEffectExampleMac` — macOS

## Building

Build the package with Swift Package Manager:

```bash
swift build
```

## License

EdgeEffectKit is available under the MIT license. See [LICENSE](LICENSE) for details.
