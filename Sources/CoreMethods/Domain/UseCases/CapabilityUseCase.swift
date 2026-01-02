//
//  CapabilityUseCase.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 13/11/25.
//

import Foundation
#if SWIFT_PACKAGE
    import MPCore
#endif

protocol CapabilityUseCaseProtocol: Sendable {
    func sendDeviceData(
        configuration: CoreMethods.Configuration,
        cardTokenId: String,
        appId: String,
        deviceData: String,
        referenceNumber: String,
        ephemeralPublicKey: String,
        transactionID: String,
        threeDSVersion: String
    ) async throws -> MPThreeDSResponse

    func getChallengeParameters(_ id: String) async throws -> MPThreeDSChallengeParameters
}

final class CapabilityUseCase: CapabilityUseCaseProtocol {
    private let repository: ThreeDSRepositoryProtocol

    init(
        repository: ThreeDSRepositoryProtocol
    ) {
        self.repository = repository
    }

    func sendDeviceData(
        configuration: CoreMethods.Configuration,
        cardTokenId: String,
        appId: String,
        deviceData: String,
        referenceNumber: String,
        ephemeralPublicKey: String,
        transactionID: String,
        threeDSVersion: String
    ) async throws -> MPThreeDSResponse {
        guard let dataEphemeralKey = ephemeralPublicKey.data(using: .utf8) else {
            throw CoreMethodsError.errorGettingEphemeralKey
        }

        guard let ephemeralKey = try? JSONSerialization.jsonObject(with: dataEphemeralKey, options: []) as? [String: Any] else {
            throw CoreMethodsError.errorGettingEphemeralKey
        }

        let curve = ephemeralKey["crv"] as? String ?? ""
        let keyType = ephemeralKey["kty"] as? String ?? ""
        let x = ephemeralKey["x"] as? String ?? ""
        let y = ephemeralKey["y"] as? String ?? ""

        let body = MPThreeDSAuthRequestParametersBody(
            appId: appId,
            integratorSDKVersion: MPSDKVersion.version,
            threeDSSDKVersion: threeDSVersion,
            cardTokenId: cardTokenId,
            deviceRenderOptions: DeviceRenderOptions(
                interface: configuration.threeDS.deviceRenderOptions.interface,
                uiTypes: configuration.threeDS.deviceRenderOptions.uiTypes
            ),
            encData: deviceData,
            ephemPubKey: EphemPubKey(curve: curve, keyType: keyType, x: x, y: y),
            maxTimeout: configuration.threeDS.maxTimeout,
            protocolVersion: configuration.threeDS.protocolVersion,
            referenceNumber: referenceNumber,
            transId: transactionID
        )

        return try await repository.postSDKData(body)
    }

    func getChallengeParameters(_ id: String) async throws -> MPThreeDSChallengeParameters {
        return MPThreeDSChallengeParameters(
            threeDSServerTransID: "",
            acsReferenceNumber: "",
            dsTransID: "",
            acsTransID: "",
            acsSignedContent: ""
        )
    }
}
