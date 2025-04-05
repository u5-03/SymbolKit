// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SymbolKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14), .visionOS(.v1)],
    products: [
        .library(
            name: "SymbolKit",
            targets: ["SymbolKit"]),
    ],
    targets: [
        .target(
            name: "SymbolKit"),
        .testTarget(
            name: "SymbolKitTests",
            dependencies: ["SymbolKit"]
        ),
    ],
    swiftLanguageModes: [.v5]
)
