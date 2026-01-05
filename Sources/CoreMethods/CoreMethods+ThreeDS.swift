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
    
    
    func challengeParameters(_ id: String) async throws -> MPThreeDSChallengeParameters {
        return try await capabilityUseCase.getChallengeParameters(id)
    }
    
    
    func finishChallenge(_ id: String) async throws {
        let _ = try await capabilityUseCase.patchChallenge(id, status: .completed, errorCode: nil, errorType: nil)
    }
    
    func cancelChallenge(_ id: String) async throws {
        let _ = try await capabilityUseCase.patchChallenge(id, status: .cancelled, errorCode: nil, errorType: nil)

    }
    
    func errorChallenge(_ id: String, errorCode: String, errorMessageType: String) async throws {
        let _ = try await capabilityUseCase.patchChallenge(id, status: .error, errorCode: errorCode, errorType: errorMessageType)

    }
    
    func timeoutChallenge(_ id: String) async throws {
        let _ = try await capabilityUseCase.patchChallenge(id, status: .timeout, errorCode: nil, errorType: nil)
    }
}
