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
        transactionID: String
    ) async throws -> ThreeDSDeviceDataResponse

    func getChallengeParameters(_ id: String) async throws -> MPThreeDSChallengeParameters
    func patchChallenge(
        _ id: String,
        status: MPThreeDSUpdateStatusBody.Status,
        errorCode: String?,
        errorType: String?
    ) async throws -> Data

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
        transactionID: String
    ) async throws -> ThreeDSDeviceDataResponse {
        guard let dataEphemeralKey = ephemeralPublicKey.data(using: .utf8) else {
            throw CoreMethodsError.errorGettingEphemeralKey
        }

        guard let ephemeralKey = try?
                JSONSerialization.jsonObject(with: dataEphemeralKey, options: []) as? [String: Any]
        else {
            throw CoreMethodsError.errorGettingEphemeralKey
        }

        let curve = ephemeralKey["crv"] as? String ?? ""
        let keyType = ephemeralKey["kty"] as? String ?? ""
        let xEphemeral = ephemeralKey["x"] as? String ?? ""
        let yEphemeral = ephemeralKey["y"] as? String ?? ""

        let body = MPThreeDSAuthRequestParametersBody(
            appId: appId,
            integratorSDKVersion: MPSDKVersion.version,
            threeDSSDKVersion: configuration.threeDS.sdkVersion,
            cardTokenId: cardTokenId,
            deviceRenderOptions: DeviceRenderOptions(
                interface: configuration.threeDS.deviceRenderOptions.interface,
                uiTypes: configuration.threeDS.deviceRenderOptions.uiTypes
            ),
            encData: deviceData,
            ephemPubKey: EphemPubKey(curve: curve, keyType: keyType, xEphem: xEphemeral, yEphem: yEphemeral),
            maxTimeout: configuration.threeDS.maxTimeout,
            protocolVersion: configuration.threeDS.protocolVersion,
            referenceNumber: referenceNumber,
            transId: transactionID
        )

        return try await repository.postSDKData(body)
    }

    func getChallengeParameters(_ id: String) async throws -> MPThreeDSChallengeParameters {
        let response: MPThreeDSChallengeResponse = try await repository.getChallenge(id)
        
        return MPThreeDSChallengeParameters(
            status: MPThreeDSChallengeParameters.ChallengeStatus(rawValue: response.status) ?? .authenticated,
            acsReferenceNumber: response.data?.acsReferenceNumber ?? "",
            dsTransID: response.data?.threeDSServerTransID ?? "",
            acsTransID: response.data?.acsTransID ?? "",
            acsSignedContent: response.data?.acsSignedContent ?? ""
        )
    }
    func patchChallenge(
        _ id: String,
        status: MPThreeDSUpdateStatusBody.Status,
        errorCode: String? = nil,
        errorType: String? = nil
    ) async throws -> Data {
        var errorDetail: MPThreeDSUpdateStatusBody.ErrorDetail?
        if let errorCode, let errorType {
            errorDetail = .init(type: errorType, code: errorCode)
        }
        let body = MPThreeDSUpdateStatusBody(status: status, errorDetail: errorDetail)
        
        return try await repository.patchChallenge(id, body: body)
    }

}
