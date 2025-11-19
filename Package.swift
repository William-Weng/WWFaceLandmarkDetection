// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWFaceLandmarkDetection",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "WWFaceLandmarkDetection", targets: ["WWFaceLandmarkDetection"]),
    ],
    dependencies: [
        .package(url: "https://github.com/William-Weng/WWAutolayoutConstraint", from: "0.6.1")
    ],
    targets: [
        .target(name: "WWFaceLandmarkDetection", dependencies: ["WWAutolayoutConstraint"], resources: [.copy("Privacy")]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
