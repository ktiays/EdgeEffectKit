// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EdgeEffectKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(name: "EdgeEffectKit", targets: ["EdgeEffectKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/ktiays/QuartzFilters.git", from: "1.1.0"),
        .package(url: "https://github.com/ktiays/With.git", from: "2.1.4"),
        .package(url: "https://github.com/Helixform/SwiftyRuntime.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "EdgeEffectKit",
            dependencies: [
                "QuartzFilters",
                "With",
                "SwiftyRuntime",
            ]
        )
    ]
)
