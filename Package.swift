// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ipalint",
    dependencies: [
        .package(url: "https://github.com/apple/swift-tools-support-core.git", .upToNextMajor(from: "0.1.10")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "0.3.1")),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.3"),
    ],
    targets: [
        .target(
            name: "ipalint",
            dependencies: ["IPALintCommand"]
        ),
        .target(
            name: "IPALintCommand",
            dependencies: ["IPALintCore", "SwiftToolsSupport-auto", "ArgumentParser"]
        ),
        .target(
            name: "IPALintCore",
            dependencies: ["SwiftToolsSupport-auto", "Yams"]
        ),
        .testTarget(
            name: "IPALintFixtures",
            dependencies: []
        ),
        .testTarget(
            name: "IPALintCoreTests",
            dependencies: ["IPALintCore", "IPALintFixtures"]
        ),
        .testTarget(
            name: "IPALintIntegrationTests",
            dependencies: ["IPALintCommand", "IPALintCore", "IPALintFixtures"]
        ),
    ]
)
