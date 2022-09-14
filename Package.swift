// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BreadCrumbControl",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "BreadCrumbControl",
            targets: ["BreadCrumbControl"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "BreadCrumbControl",
            resources: [
                .copy("Resources/BreadCrumbControl.xcassets"),
            ]),
    ]
)
