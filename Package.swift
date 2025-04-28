// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let package = Package(
    name: "MercadoPagoSDK",
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
            dependencies: ["MPAnalytics", "DeviceFingerPrint"]
        ),
        .target(
            name: "CoreMethods",
            dependencies: ["MPCore"]
        ),
        .target(
            name: "MPAnalytics"
        ),
        
        .binaryTarget(
            name: "DeviceFingerPrint",
            path: "Sources/Framework/DeviceFingerPrint.xcframework"
        ),
        
        //Tests
        .target(
            name: "CommonTests",
            dependencies: ["MPCore"],
            path: "Tests/Common"
        ),
        .testTarget(
            name: "CoreMethodsTests",
            dependencies: ["CoreMethods", "CommonTests"]
        ),
        .testTarget(
            name: "AnalyticsTests",
            dependencies: ["MPAnalytics"]
        ),
        .testTarget(
            name: "MPCoreTests",
            dependencies: ["MPCore", "CommonTests"]
        ),
        .testTarget(
            name: "SnapshotTests",
            dependencies: [
                "CoreMethods",
                "CommonTests",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        )
    ]
)
