// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ipalint",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(name: "ipalint", targets: ["ipalint"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-tools-support-core.git", .upToNextMajor(from: "0.7.3")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.6.2")),
        .package(url: "https://github.com/jpsim/Yams.git", from: "6.2.0"),
        .package(url: "https://github.com/macvmio/SwiftCommons.git", .upToNextMajor(from: "0.2.1")),
    ],
    targets: [
        .executableTarget(
            name: "ipalint",
            dependencies: [
                .target(name: "IPALintCommand"),
            ]
        ),
        .target(
            name: "IPALintCommand",
            dependencies: [
                .target(name: "IPALintCore"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
                .product(name: "SCInject", package: "SwiftCommons"),
            ]
        ),
        .target(
            name: "IPALintCore",
            dependencies: [
                .product(name: "Yams", package: "Yams"),
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
                .product(name: "SCInject", package: "SwiftCommons"),
            ]
        ),
        .testTarget(
            name: "IPALintCoreTests",
            dependencies: [
                .target(name: "IPALintCore"),
            ]
        ),
        .testTarget(
            name: "IPALintIntegrationTests",
            dependencies: [
                .target(name: "IPALintCommand"),
                .target(name: "IPALintCore"),
            ]
        ),
    ]
)
