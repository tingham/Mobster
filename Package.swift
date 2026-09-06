// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Mobster",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(name: "Mobster", targets: ["Mobster"]),
        .library(name: "MobsterFixture", targets: ["MobsterFixture"]),
    ],
    targets: [
        .target(
            name: "Mobster",
            resources: [.process("Resources")],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        // The fixture mints identifiers, which Mobster is forbidden to do, so it sits in its own target rather than inside the library.
        .target(
            name: "MobsterFixture",
            dependencies: ["Mobster"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(name: "MobsterTests", dependencies: ["Mobster"]),
        .testTarget(name: "MobsterFixtureTests", dependencies: ["MobsterFixture"]),
    ]
)
