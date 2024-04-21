// swift-tools-version: 5.9

import PackageDescription

// MARK: - Package Configuration

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
            dependencies: ["ChessKitEngineCore"]
        ),
        .target(
            name: "ChessKitEngineCore",
            cxxSettings: [
                .headerSearchPath("Engines/lc0/"),
                .headerSearchPath("Engines/lc0/src"),
                .headerSearchPath("Engines/lc0/subprojects/eigen-3.4.0"),
                .define("NNUE_EMBEDDING_OFF"),
                .define("NO_PEXT"),
                .unsafeFlags([
                    // suppress Stockfish warnings
                    "-Wno-deprecated-declarations",
                    "-Wno-shorten-64-to-32"
                ])
            ],
            linkerSettings: [
                .linkedLibrary("z")
            ]
        ),
        .testTarget(
            name: "ChessKitEngineTests",
            dependencies: ["ChessKitEngine"],
            resources: [
                .copy("EngineTests/Resources/192x15_network")
            ]
        )
    ],
    cxxLanguageStandard: .gnucxx17
)

// MARK: - ChessKitEngineCore excludes

package.targets.first { $0.name == "ChessKitEngineCore" }?.exclude = [
    // lc0
    "Engines/lc0/build",
    "Engines/lc0/cross-files",
    "Engines/lc0/dist",
    "Engines/lc0/libs",
    "Engines/lc0/scripts",
    "Engines/lc0/subprojects/eigen-3.4.0/bench",
    "Engines/lc0/subprojects/eigen-3.4.0/blas",
    "Engines/lc0/subprojects/eigen-3.4.0/ci",
    "Engines/lc0/subprojects/eigen-3.4.0/cmake",
    "Engines/lc0/subprojects/eigen-3.4.0/debug",
    "Engines/lc0/subprojects/eigen-3.4.0/demos",
    "Engines/lc0/subprojects/eigen-3.4.0/doc",
    "Engines/lc0/subprojects/eigen-3.4.0/failtest",
    "Engines/lc0/subprojects/eigen-3.4.0/lapack",
    "Engines/lc0/subprojects/eigen-3.4.0/scripts",
    "Engines/lc0/subprojects/eigen-3.4.0/test",
    "Engines/lc0/subprojects/eigen-3.4.0/unsupported",
    "Engines/lc0/third_party",
    "Engines/lc0/src/main.cc",
    "Engines/lc0/src/utils/filesystem.win32.cc",
    "Engines/lc0/src/chess/board_test.cc",
    "Engines/lc0/src/chess/position_test.cc",
    "Engines/lc0/src/neural/encoder_test.cc",
    "Engines/lc0/src/syzygy/syzygy_test.cc",
    "Engines/lc0/src/utils/hashcat_test.cc",
    "Engines/lc0/src/utils/optionsparser_test.cc",
    "Engines/lc0/src/benchmark/",
    "Engines/lc0/src/lc0ctl/",
    "Engines/lc0/src/python/",
    "Engines/lc0/src/selfplay/",
    "Engines/lc0/src/trainingdata/",
    "Engines/lc0/src/neural/cuda/",
    "Engines/lc0/src/neural/dx/",
    "Engines/lc0/src/neural/onednn/",
    "Engines/lc0/src/neural/onnx/",
    "Engines/lc0/src/neural/opencl/",
    "Engines/lc0/src/neural/metal/",
    "Engines/lc0/src/neural/network_tf_cc.cc"
]
