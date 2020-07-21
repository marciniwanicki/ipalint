// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ipalint",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ipalint",
            dependencies: ["IPALintKit"]
        ),
        .target(
            name: "IPALintKit",
            dependencies: ["IPALintCore"]
        ),
        .target(
            name: "IPALintCore",
            dependencies: []
        ),
        .testTarget(
            name: "IPALintFixtures",
            dependencies: []
        ),
        .testTarget(
            name: "IPALintCoreTests",
            dependencies: ["IPALintCore", "IPALintFixtures"]
        ),
    ]
)
