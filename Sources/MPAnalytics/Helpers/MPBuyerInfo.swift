//
//  MPBuyerInfo.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 03/01/25.
//  Copyright © 2024 Mercado Pago. All rights reserved.
//
import Foundation
import UIKit

// The `MPBuyerInfo` class is responsible for gathering information about the device and network status.
// - Note: This class should be used only within the MercadoPago SDK for iOS.

package final class MPBuyerInfo: Sendable {
    /// A network monitor used to check the current network connection status.
    private let networkMonitor: NetworkMonitoring

    /// Initializes a new instance of `MPBuyerInfo`.
    ///
    /// - Parameter networkMonitor: An object that implements the `NetworkMonitoring` protocol.
    ///                             Defaults to `NetworkMonitor()`.
    package init(networkMonitor: NetworkMonitoring = NetworkMonitor()) {
        self.networkMonitor = networkMonitor
    }

    /// Retrieves the device model.
    ///
    /// - Returns: A `String` representing the device's model code, or "unknown" if it cannot be determined.
    package func getDeviceInfo() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)

        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) { ptr in
                String(validatingCString: ptr)
            }
        }

        return modelCode ?? "unknown"
    }

    /// Retrieves the iOS system version.
    ///
    /// - Returns: A `String` representing the iOS version.
    @MainActor
    package func getiOSVersion() -> String {
        UIDevice.current.systemVersion
    }

    /// Retrieves the unique identifier (UID) of the device.
    ///
    /// - Returns: A `String` representing the device's unique identifier, or an empty string if the identifier is not available.
    @MainActor
    package func getUID() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }

    /// Retrieves the current network type (e.g., WiFi, cellular).
    ///
    /// - Returns: A `String` representing the current network type.
    package func getNetworkType() -> String {
        self.networkMonitor.getCurrentNetworkType()
    }
}
