// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "MethodChainGen",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .executable(
            name: "swchaingen",
            targets: ["MethodChainGen"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "1.2.2")),
        .package(url: "https://github.com/apple/swift-syntax.git", .upToNextMinor(from: "508.0.0"))
    ],
    targets: [
        .executableTarget(
            name: "MethodChainGen",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "MethodChainGenTests",
            dependencies: ["MethodChainGen"]
        ),
    ]
)
