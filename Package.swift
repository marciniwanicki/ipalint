// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ipalint",
    products: [
        .executable(name: "ipalint", targets: ["ipalint"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-tools-support-core.git", .upToNextMajor(from: "0.2.7")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.1"),
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
            ]
        ),
        .target(
            name: "IPALintCore",
            dependencies: [
                .product(name: "Yams", package: "Yams"),
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
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
