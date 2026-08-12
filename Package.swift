// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WhatsNewKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "WhatsNewKit", targets: ["WhatsNewKit"]),
    ],
    targets: [
        .target(name: "WhatsNewKit"),
        .testTarget(
            name: "WhatsNewKitTests",
            dependencies: ["WhatsNewKit"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
