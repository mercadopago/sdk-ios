//
//  CoreMethods+ThreeDS.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 02/01/26.
//

extension CoreMethods {
    
    func sendDeviceData(
        cardTokenId: String,
        appId: String,
        deviceData: String,
        threeDSVersion: String,
        referenceNumber: String,
        ephemeralPublicKey: String,
        transactionID: String,
    ) async throws {
        let _ = try await capabilityUseCase.sendDeviceData(
            configuration: configuration,
            cardTokenId: cardTokenId,
            appId: appId,
            deviceData: deviceData,
            referenceNumber: referenceNumber,
            ephemeralPublicKey: ephemeralPublicKey,
            transactionID: transactionID,
            threeDSVersion: threeDSVersion
        )
    }
    
}
