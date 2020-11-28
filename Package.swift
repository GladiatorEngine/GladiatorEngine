// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GladiatorEngine",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Engine",
            targets: ["Engine"]),
        .library(
            name: "AssetManager",
            targets: ["AssetManager"]),
        .library(
            name: "GameNetwork",
            targets: ["Network"]),
        .library(
            name: "Logger",
            targets: ["Logger"]),
        .executable(
            name: "game-network-server-runner",
            targets: ["GameNetworkServerRunner"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", .exact("1.1.2")),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Engine",
            dependencies: ["AssetManager", "ShaderHeaders", "Logger", "Network"],
            resources: [.process("Metal")]),
        .testTarget(
            name: "EngineTests",
            dependencies: ["Engine"]),
        .target(
            name: "AssetManager",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .byName(name: "AssetManagerC"),
                .byName(name: "Assets"),
                .byName(name: "Logger")
            ]),
        .target(
            name: "AssetManagerC",
            dependencies: ["Assets"]),
        .target(
            name: "Assets",
            dependencies: []),
        .testTarget(
            name: "AssetManagerTests",
            dependencies: ["AssetManager"]),
        .target(
            name: "ShaderHeaders",
            dependencies: []),
        .target(
            name: "Logger",
            dependencies: ["LoggerC"]),
        .target(
            name: "LoggerC",
            dependencies: []),
        .target(
            name: "Network",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
            ]),
        .target(
            name: "GameNetworkServerRunner",
            dependencies: [
                .byName(name: "Network"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
    ]
)
