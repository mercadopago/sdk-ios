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
    func sendDeviceData(_ requestParameters: MPThreeDSAuthRequestParametersBody) async throws -> MPThreeDSResponse
    func getChallengeParameters(_ id: String) async throws -> MPThreeDSChallengeParameters

}

final class CapabilityUseCase: CapabilityUseCaseProtocol {
    private let repository: CoreMethodsRepositoryProtocol

    init(
        repository: CoreMethodsRepositoryProtocol
    ) {
        self.repository = repository
    }

    func sendDeviceData(_ requestParameters: MPThreeDSAuthRequestParametersBody) async throws -> MPThreeDSResponse {
        return try await repository.postSDKData(requestParameters)
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
