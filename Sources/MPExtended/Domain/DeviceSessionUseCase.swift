//
//  DeviceSessionUseCase.swift
//  MercadoPagoSDK
//

import Foundation
#if SWIFT_PACKAGE
    import MPCore
#endif

protocol DeviceSessionUseCaseProtocol: Sendable {
    func deviceSession() async throws -> MPDeviceSession
}

final class DeviceSessionUseCase: DeviceSessionUseCaseProtocol {
    private let repository: MPExtendedRepositoryProtocol

    typealias Dependency = HasFingerPrint
    private let dependencies: Dependency

    init(
        dependencies: Dependency,
        repository: MPExtendedRepositoryProtocol
    ) {
        self.dependencies = dependencies
        self.repository = repository
    }

    func deviceSession() async throws -> MPDeviceSession {
        let deviceData = await dependencies.fingerPrint.getDeviceData()
        let body = buildBody(from: deviceData)
        let session = try await repository.deviceSession(body: body)
        return MPDeviceSession(session: session)
    }
}

private extension DeviceSessionUseCase {
    func buildBody(from deviceData: Data?) -> DeviceSessionBody {
        var fingerPrint: [String: Any]?

        if let data = deviceData,
           let root = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            fingerPrint = root["fingerprint"] as? [String: Any]
        }

        let siteId = MercadoPagoSDK.shared.configuration?.country.getSiteId() ?? ""

        return DeviceSessionBody(siteId: siteId, fingerPrint: fingerPrint)
    }
}
