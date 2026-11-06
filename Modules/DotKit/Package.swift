// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "DotKit",
    defaultLocalization: "en",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "DotCore", targets: ["DotCore"]),
        .library(name: "DotDesign", targets: ["DotDesign"])
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift", from: "7.10.0")
    ],
    targets: [
        .target(name: "DotDesign"),
        .target(name: "DotCore", dependencies: [.product(name: "GRDB", package: "GRDB.swift")]),
        .testTarget(name: "DotDesignTests", dependencies: ["DotDesign"]),
        .testTarget(
            name: "DotCoreTests",
            dependencies: ["DotCore"],
            resources: [.copy("Fixtures")]
        )
    ]
)
