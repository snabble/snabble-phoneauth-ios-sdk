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
        .package(url: "https://github.com/lachlanbell/SwiftOTP", from: "3.0.1"),
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
            resources: [
                .process("Resources/countries.json")
            ]
        ),
        .testTarget(
            name: "SnabblePhoneAuthTests",
            dependencies: ["SnabbleNetwork", "SnabblePhoneAuth"],
            path: "Tests/Core"
        ),
        .target(
            name: "SnabbleNetwork",
            dependencies: [
                "SwiftOTP"
            ],
            path: "Sources/Network"
        ),
        .testTarget(
            name: "SnabbleNetworkTests",
            dependencies: ["SnabbleNetwork"],
            path: "Tests/Network",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
