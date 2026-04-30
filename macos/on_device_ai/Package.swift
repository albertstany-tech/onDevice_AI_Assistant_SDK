// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "on_device_ai",
    platforms: [
        .macOS("11.0")
    ],
    products: [
        .library(name: "on_device_ai", targets: ["on_device_ai"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "on_device_ai",
            dependencies: [],
            path: "../Classes",
            linkerSettings: [
                .linkedFramework("NaturalLanguage"),
                .linkedFramework("Vision"),
                .linkedFramework("CoreML"),
            ]
        ),
    ]
)
