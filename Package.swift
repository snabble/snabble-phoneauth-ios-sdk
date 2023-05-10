// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SnabblePhoneAuth",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SnabblePhoneAuth",
            targets: ["SnabblePhoneAuth"]),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint", exact: "0.51.0"),
        .package(url: "https://github.com/snabble/OneTimePassword.git", from: "4.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SnabblePhoneAuth",
            dependencies: [
                "SnabbleNetwork"
            ],
            path: "Sources/Core",
            plugins: [
                .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
            ]
        ),
        .testTarget(
            name: "SnabblePhoneAuthTests",
            dependencies: ["SnabblePhoneAuth"],
            path: "Tests/Core"
        ),
        .target(
            name: "SnabbleNetwork",
            dependencies: [
                "OneTimePassword"
            ],
            path: "Sources/Network"
        ),
        .testTarget(
            name: "SnabbleNetworkTests",
            dependencies: ["SnabbleNetwork"],
            path: "Tests/Network"
        )
    ]
)
