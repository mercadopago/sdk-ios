// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MercadoPagoSDK-iOS",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CoreMethods",
            targets: ["CoreMethods"]
        )
    ],
    dependencies: [
        // SwiftLint plugin dependency
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.57.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CoreMethods",
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),
        .testTarget(
            name: "CoreMethodsTests",
            dependencies: ["CoreMethods"]
        )
    ]
)
