// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "ChessKitEngine",
    platforms: [
        .iOS(.v16),
        .watchOS(.v9),
        .macOS(.v13),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "ChessKitEngine",
            targets: ["ChessKitEngine"]
        )
    ],
    targets: [
        .target(
            name: "ChessKitEngine",
            dependencies: ["ChessKitEngine_ObjC"]
        ),
        .target(
            name: "ChessKitEngine_ObjC",
            dependencies: ["ChessKitEngine_Cxx"]
        ),
        .executableTarget(name: "ChessKitEngine_Cxx"),
        .testTarget(
            name: "ChessKitEngineTests",
            dependencies: ["ChessKitEngine"]
        ),
    ],
    cxxLanguageStandard: .gnucxx20
)
