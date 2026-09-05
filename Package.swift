// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Mobster",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(name: "Mobster", targets: ["Mobster"])
    ],
    targets: [
        .target(name: "Mobster"),
        .testTarget(name: "MobsterTests", dependencies: ["Mobster"]),
    ]
)
