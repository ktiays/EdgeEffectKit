# EdgeEffectKit

EdgeEffectKit is an experimental Swift package for building adaptive edge effects around scrollable content on iOS and macOS. It explores backdrop capture, masked variable blur, and luminance-aware blending for softer scroll-boundary treatments.

The package is designed for UIKit and AppKit projects that need polished edge treatments without rebuilding the effect stack in every view controller.

## Status

EdgeEffectKit is still under active development. Its public API and integration model are not stable yet, so this README intentionally avoids usage examples until the core design is finalized.

## Features

- Cross-platform support for iOS 15+ and macOS 12+.
- Experimental edge effects for scrollable interfaces.
- Backdrop capture and masked blur pipeline.
- Luminance-aware blending for smoother edge transitions.
- Swift Package Manager integration.

## Requirements

- Swift 6.0+
- iOS 15.0+
- macOS 12.0+
- Swift Package Manager

## Important Note

EdgeEffectKit uses private Core Animation and backdrop APIs, including `CABackdropLayer` and private layer properties. This makes it suitable for experimentation, prototypes, internal tools, and controlled distribution environments. Review your distribution requirements carefully before using it in App Store software.

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

If you are using Xcode, you can also add the package through **File > Add Package Dependencies...** and enter:

```text
https://github.com/ktiays/EdgeEffectKit.git
```

## Examples

The repository includes example projects for both supported platforms:

- `Examples/EdgeEffectExample` for iOS.
- `Examples/EdgeEffectExampleMac` for macOS.

Open `Examples/EdgeEffectExamples.xcworkspace` to run the sample apps.

## Development

Build the package with Swift Package Manager:

```bash
swift build
```

The package currently contains the library target and platform example projects.

## License

No license file is currently included in this repository. Add a license before distributing or reusing this package outside its intended project context.
