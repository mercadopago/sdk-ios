// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

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
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.17.6")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MPCore",
            dependencies: ["MPAnalytics"]
        ),
        .target(
            name: "CoreMethods",
            dependencies: ["MPCore"]
        ),
        .target(
            name: "MPAnalytics"
        ),
        
        //Tests
        .testTarget(
            name: "CoreMethodsTests",
            dependencies: ["CoreMethods"]
        ),
        .testTarget(
            name: "AnalyticsTests",
            dependencies: ["MPAnalytics"]
        ),
        .testTarget(
            name: "MPCoreTests",
            dependencies: ["MPCore"]
        ),
        .testTarget(
            name: "SnapshotTests",
            dependencies: [
                "CoreMethods",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        )
    ]
)
