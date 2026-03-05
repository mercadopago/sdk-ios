//
//  NetworkMonitor.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 03/01/25.
//  Copyright © 2024 Mercado Pago. All rights reserved.
//

import CoreTelephony
import SystemConfiguration

/// The `NetworkMonitoring` protocol defines a method for checking the current network type.
package protocol NetworkMonitoring: Sendable {
    /// Retrieves the current type of network connection.
    ///
    /// - Returns: A `String` representing the current network type, such as "wifi", "cellular", or "offline".
    func getCurrentNetworkType() -> String
}

/// The `NetworkMonitor` class provides an implementation of the `NetworkMonitoring` protocol.
/// It is used to determine the current network connection type.
/// - Note: This class relies on the SystemConfiguration framework to access network reachability.
package final class NetworkMonitor: NetworkMonitoring {
    /// Determines the current network connection type.
    ///
    /// The method checks the reachability status of "www.apple.com" to determine
    /// if the device is online and if the connection is over WiFi or cellular.
    ///
    /// - Returns: A `String` value, which can be "wifi", "5g", "4g", "3g", "2g", or "unknown" depending on the connection status.
    package func getCurrentNetworkType() -> String {
        var flags = SCNetworkReachabilityFlags()

        if let reachability = SCNetworkReachabilityCreateWithName(nil, "www.apple.com") {
            if SCNetworkReachabilityGetFlags(reachability, &flags) {
                let isWWAN = flags.contains(.isWWAN)

                guard isWWAN else {
                    return "wifi"
                }
            }
        }

        return self.verifyCarrierType()
    }

    private func verifyCarrierType() -> String {
        let networkInfo = CTTelephonyNetworkInfo()
        let carrierType = networkInfo.serviceCurrentRadioAccessTechnology

        guard let carrierTypeName = carrierType?.first?.value else {
            return "unknown"
        }

        switch carrierTypeName {
        case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x:
            return "2g"
        case CTRadioAccessTechnologyWCDMA,
             CTRadioAccessTechnologyHSDPA,
             CTRadioAccessTechnologyHSUPA,
             CTRadioAccessTechnologyCDMAEVDORev0,
             CTRadioAccessTechnologyCDMAEVDORevA,
             CTRadioAccessTechnologyCDMAEVDORevB,
             CTRadioAccessTechnologyeHRPD:
            return "3g"
        case CTRadioAccessTechnologyLTE:
            return "4g"
        default:
            return "5g"
        }
    }
}
