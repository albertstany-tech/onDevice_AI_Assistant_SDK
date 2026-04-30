// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "on_device_ai",
    platforms: [
        .macOS("11.0")
    ],
    products: [
        // The library name must match the module name used by Flutter.
        .library(name: "on_device_ai", targets: ["on_device_ai"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "on_device_ai",
            dependencies: [],
            // Points to the same Classes/ directory as the .podspec does.
            path: "Classes",
            // The NaturalLanguage and Vision frameworks are system frameworks
            // already included in the macOS SDK — no external dependencies needed.
            linkerSettings: [
                .linkedFramework("NaturalLanguage"),
                .linkedFramework("Vision"),
                .linkedFramework("CoreML"),
            ]
        ),
    ]
)
