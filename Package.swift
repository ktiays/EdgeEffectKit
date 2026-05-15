// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EdgeEffectKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "EdgeEffectKit", targets: ["EdgeEffectKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/ktiays/QuartzFilters.git", from: "1.0.0"),
        .package(url: "https://github.com/ktiays/with.git", from: "2.1.4")
    ],
    targets: [
        .target(
            name: "EdgeEffectKit",
            dependencies: [
                "CEdgeEffectKit",
                .product(name: "QuartzFilters", package: "QuartzFilters"),
                .product(name: "With", package: "with")
            ]
        ),
        .target(
            name: "CEdgeEffectKit",
            publicHeadersPath: "include"
        )
    ]
)
