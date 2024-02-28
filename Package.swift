// swift-tools-version:5.9

//
// This source file is part of the SpeziFileFormats open source project
// 
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import PackageDescription


let package = Package(
    name: "SpeziFileFormats",
    platforms: [
        .iOS(.v15),
        .watchOS(.v7),
        .visionOS(.v1),
        .macOS(.v12)
    ],
    products: [
        .library(name: "ByteCoding", targets: ["ByteCoding"]),
        .library(name: "XCTByteCoding", targets: ["XCTByteCoding"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.59.0")
    ],
    targets: [
        .target(
            name: "ByteCoding",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOFoundationCompat", package: "swift-nio")
            ]
        ),
        .target(
            name: "XCTByteCoding",
            dependencies: [
                .target(name: "ByteCoding")
            ]
        ),
        .testTarget(
            name: "ByteCodingTests",
            dependencies: [
                .target(name: "ByteCoding"),
                .target(name: "XCTByteCoding")
            ]
        )
    ]
)
