// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SemanticPen",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SemanticPen",
            targets: ["SemanticPen"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SemanticPen",
            dependencies: []
        ),
        .testTarget(
            name: "SemanticPenTests",
            dependencies: ["SemanticPen"]
        ),
    ]
)