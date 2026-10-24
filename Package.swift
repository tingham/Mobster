// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Mobster",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(name: "Mobster", targets: ["Mobster"]),
        .library(name: "MobsterFixture", targets: ["MobsterFixture"]),
    ],
    dependencies: [
        .package(url: "git@github.com:tingham/Whiplash.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Mobster",
            dependencies: [.product(name: "Whiplash", package: "Whiplash")],
            resources: [.process("Resources")],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .target(
            name: "MobsterFixture",
            dependencies: ["Mobster"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(name: "MobsterTests", dependencies: ["Mobster"]),
        .testTarget(name: "MobsterFixtureTests", dependencies: ["MobsterFixture"]),
    ]
)
