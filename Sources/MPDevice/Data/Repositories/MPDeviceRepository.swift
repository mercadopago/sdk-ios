//
//  MPDeviceRepository.swift
//  MercadoPagoSDK
//

import Foundation
#if SWIFT_PACKAGE
    import MPCore
#endif

protocol MPDeviceRepositoryProtocol: Sendable {
    func deviceSession(body: DeviceSessionBody) async throws -> String
}

final class MPDeviceRepository: MPDeviceRepositoryProtocol {
    typealias Dependency = HasNetwork
    private typealias Endpoint = DeviceSessionEndpoint

    private let dependencies: Dependency

    init(dependencies: Dependency = CoreDependencyContainer.shared) {
        self.dependencies = dependencies
    }

    func deviceSession(body: DeviceSessionBody) async throws -> String {
        let response: DeviceSessionResponse = try await dependencies.networkService.request(
            Endpoint.putSession(body: body)
        )
        return response.session
    }
}
