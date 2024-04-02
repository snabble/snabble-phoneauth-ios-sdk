// swift-tools-version: 5.9
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
        .package(name: "SnabbleNetwork", url: "https://github.com/snabble/snabble-network-ios-sdk", branch: "intention"),
   ],
    targets: [
        .target(
            name: "SnabblePhoneAuth",
            dependencies: [
                "SnabbleNetwork"
            ],
            path: "Sources/Core",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SnabblePhoneAuthTests",
            dependencies: ["SnabblePhoneAuth"],
            path: "Tests/Core",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
