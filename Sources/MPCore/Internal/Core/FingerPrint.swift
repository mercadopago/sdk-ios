//
//  FingerPrint.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 16/04/25.
//

import DeviceFingerPrint
import Foundation

package protocol HasFingerPrint: Sendable {
    var fingerPrint: FingerPrintProtocol { get }
}

package protocol FingerPrintProtocol: Sendable {
    @MainActor
    func getDeviceData() async -> Data?
}

package final class FingerPrint: FingerPrintProtocol {
    package init() {}

    @MainActor
    package func getDeviceData() async -> Data? {
        #if targetEnvironment(simulator)
            // The vendored DeviceFingerPrint framework traps when collecting device data in the simulator.
            // Fingerprint data is optional for tokenization, so keep simulator flows usable without changing
            // the physical-device behavior.
            return nil
        #else
            return Device.getInfoAsJsonData()
        #endif
    }
}
