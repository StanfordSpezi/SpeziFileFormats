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
        .iOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1),
        .macOS(.v13),
        .tvOS(.v16)
    ],
    products: [
        .library(name: "EDFFormat", targets: ["EDFFormat"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/SpeziNetworking.git", from: "2.0.1")
    ],
    targets: [
        .target(
            name: "EDFFormat",
            dependencies: [
                .product(name: "ByteCoding", package: "SpeziNetworking"),
                .product(name: "SpeziNumerics", package: "SpeziNetworking")
            ]
        ),
        .testTarget(
            name: "EDFFormatTests",
            dependencies: [
                .product(name: "ByteCoding", package: "SpeziNetworking"),
                .target(name: "EDFFormat")
            ]
        )
    ]
)
