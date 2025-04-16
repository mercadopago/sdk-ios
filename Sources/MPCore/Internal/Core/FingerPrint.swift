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
    func execute()

    @MainActor
    func getDeviceData() async -> Data?
}

package final class FingerPrint: FingerPrintProtocol {
    package init() {}

    @MainActor
    package func getDeviceData() async -> Data? {
        return Device.getInfoAsJsonData()
    }

    package func execute() {
        Device.execute()
    }
}
