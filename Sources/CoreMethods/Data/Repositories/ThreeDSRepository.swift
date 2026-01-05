//
//  ThreeDSRepository.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 02/01/26.
//

import Foundation
#if SWIFT_PACKAGE
    import MPCore
#endif

package final class ThreeDSRepository: ThreeDSRepositoryProtocol {
    typealias Dependency = HasNetwork
    private typealias Endpoint = ThreeDSEndpoint

    let dependencies: Dependency

    init(
        dependencies: Dependency = CoreDependencyContainer.shared
    ) {
        self.dependencies = dependencies
    }

    func postSDKData(_ data: MPThreeDSAuthRequestParametersBody) async throws -> ThreeDSDeviceDataResponse {
        return try await self.dependencies.networkService.request(
            Endpoint.postDeviceData(body: data)
        )
    }
    
    func getChallenge(_ id: String) async throws -> MPThreeDSChallengeResponse {
        return try await self.dependencies.networkService.request(
            Endpoint.getChallenge(id: id)
        )
    }
}

