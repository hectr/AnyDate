// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "AnyDate",
    products: [
        .library(
            name: "AnyDate",
            targets: ["AnyDate"]),
    ],
    dependencies: [
         .package(url: "https://github.com/hectr/swift-idioms", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "AnyDate",
            dependencies: ["Idioms"]),
        .testTarget(
            name: "AnyDateTests",
            dependencies: ["AnyDate"]),
    ]
)
