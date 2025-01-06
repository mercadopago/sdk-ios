//
//  MPSellerInfo.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 03/01/25.
//  Copyright © 2024 Mercado Pago. All rights reserved.
//
import Foundation

// The `MPSellerInfo` class provides information about the app's setup environment,
// such as package manager and target OS version.

package final class MPSellerInfo: Sendable {
    /// An enumeration defining the possible package managers used to distribute the app.
    package enum PackageManager: String {
        /// Represents the CocoaPods package manager.
        case cocoapods = "cocoapods"
        /// Represents the Swift Package Manager.
        case spm = "spm"
        /// Represents an Xcode project without a package manager.
        case xcode = "xcode"
    }

    /// Initializes a new instance of `MPSellerInfo`.
    package init() {}

    /// Retrieves the minimum target iOS version specified for the app.
    ///
    /// - Returns: A `String` formatted as "iOS X.Y" representing the minimum OS version,
    ///            or an empty string if not specified.
    package func getTargetMinimum() -> String {
        if let minimumVersion = Bundle.main.object(forInfoDictionaryKey: "MinimumOSVersion") as? String {
            return "iOS \(minimumVersion)"
        }

        return ""
    }

    /// Determines the package manager used for app distribution.
    ///
    /// - Returns: A `PackageManager` value indicating the package manager being used.
    package func getDistribution() -> PackageManager {
        #if COCOAPODS
            return .cocoapods
        #elseif SWIFT_PACKAGE
            return .spm
        #else
            return .xcode
        #endif
    }
}
