//
//  CoreMethods+ThreeDS.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 02/01/26.
//

extension CoreMethods {
    
    /// Sends 3DS device data to mercado pago.
    ///
    /// This call maps to the 3DS Device Data Collection step and should be executed
    /// right after the card token is created and the 3DS SDK finishes gathering device signals.
    /// - Parameters:
    ///   - cardTokenId: Token returned by card tokenization.
    ///   - appId: SDK application identifier.
    ///   - deviceData: Encrypted device data payload produced by the 3DS SDK.
    ///   - threeDSVersion: 3DS SDK version.
    ///   - referenceNumber: SDK reference number.
    ///   - ephemeralPublicKey: Ephemeral public key (JWK JSON string) used for encryption.
    ///   - transactionID: transaction ID (transId).
    public func sendDeviceData(
        cardTokenId: String,
        appId: String,
        deviceData: String,
        threeDSVersion: String,
        referenceNumber: String,
        ephemeralPublicKey: String,
        transactionID: String,
    ) async throws {
        _ = try await capabilityUseCase.sendDeviceData(
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
    
    /// Retrieves challenge parameters required by the ACS to start the challenge flow.
    ///
    /// Use the returned data (acsReferenceNumber, dsTransID, acsTransID, acsSignedContent)
    /// to initialize the challenge within the 3DS SDK UI component.
    /// - Parameter id: Challenge identifier returned by the backend.
    /// - Returns: Challenge parameters mapped to fields.
    public func challengeParameters(_ id: String) async throws -> MPThreeDSChallengeParameters {
        return try await capabilityUseCase.getChallengeParameters(id)
    }
    
    /// Marks the challenge as successfully completed
    /// - Parameter id: Challenge identifier.
    public func finishChallenge(_ id: String) async throws {
        _ = try await capabilityUseCase.patchChallenge(id, status: .completed, errorCode: nil, errorType: nil)
    }
    
    /// Cancels the challenge when the user aborts or closes the flow.
    /// - Parameter id: Challenge identifier.
    public func cancelChallenge(_ id: String) async throws {
        _ = try await capabilityUseCase.patchChallenge(id, status: .cancelled, errorCode: nil, errorType: nil)
    }
    
    /// Reports a challenge failure with the provided error context.
    /// - Parameters:
    ///   - id: Challenge identifier.
    ///   - errorCode: Backend/ACS error code to log.
    ///   - errorMessageType: Error type/category as defined by the integration, use errorMessageType from getErrorMessage() of 3DS SDK
    public func errorChallenge(_ id: String, errorCode: String, errorMessageType: String) async throws {
        _ = try await capabilityUseCase.patchChallenge(
            id,
            status: .error,
            errorCode: errorCode,
            errorType: errorMessageType
        )
    }
    
    /// Marks the challenge as timed out  when the ACS UI exceeds the allowed window.
    /// - Parameter id: Challenge identifier.
    public func timeoutChallenge(_ id: String) async throws {
        _ = try await capabilityUseCase.patchChallenge(id, status: .timeout, errorCode: nil, errorType: nil)
    }
}
