// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "AnyDate",
    products: [
        .library(
            name: "AnyDate",
            targets: ["AnyDate"]),
    ],
    targets: [
        .target(
            name: "AnyDate",
            dependencies: []),
        .testTarget(
            name: "AnyDateTests",
            dependencies: ["AnyDate"]),
    ]
)
