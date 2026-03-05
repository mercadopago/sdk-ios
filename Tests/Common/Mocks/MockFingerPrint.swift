//
//  MockFingerPrint.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 16/04/25.
//
import Foundation
import MPCore

package final class MockFingerPrint: FingerPrintProtocol {
    package init() {}

    package func execute() {}

    package func getDeviceData() async -> Data? {
        return nil
    }
}
