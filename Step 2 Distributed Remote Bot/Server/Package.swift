// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.
/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Package description for the shared modules.
*/

import PackageDescription

var globalSwiftSettings: [SwiftSetting] = []

var targets: [Target] = [
    .executableTarget(
        name: "TicTacFishServer",
        dependencies: [
            .product(name: "TicTacFishShared", package: "Shared")
        ])
]

let package = Package(
    name: "TicTacFishServer",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .executable(
            name: "TicTacFishServer",
            targets: ["TicTacFishServer"])
    ],
    dependencies: [
        .package(name: "Shared", path: "../Shared")
    ],
    targets: targets.map { target in
        var swiftSettings = target.swiftSettings ?? []
        if target.type != .plugin {
            swiftSettings.append(contentsOf: globalSwiftSettings)
        }
        if !swiftSettings.isEmpty {
            target.swiftSettings = swiftSettings
        }
        return target
    }
)
