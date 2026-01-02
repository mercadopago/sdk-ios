//
//  ThreeDSUseCase.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 02/01/26.
//
import MPCore
import Foundation

protocol ThreeDSUseCaseProtocol: Sendable {
    func sendDeviceData(
        cardTokenId: String,
        appId: String,
        deviceData: String,
        messageVersion: String,
        referenceNumber: String,
        ephemeralPublicKey: String,
        transactionID: String,
        threeDSVersion: String
    ) async throws
}

final class ThreeDSUseCase: ThreeDSUseCaseProtocol {
    private let repository: ThreeDSRepositoryProtocol

    init(repository: ThreeDSRepositoryProtocol = ThreeDSRepository()) {
        self.repository = repository
    }

    func sendDeviceData(
        cardTokenId: String,
        appId: String,
        deviceData: String,
        messageVersion: String,
        referenceNumber: String,
        ephemeralPublicKey: String,
        transactionID: String,
        threeDSVersion: String,
    ) async throws {
        
        if let dataEphemeralKey = ephemeralPublicKey.data(using: .utf8) {
            do {
                if let ephemeralKey = try JSONSerialization.jsonObject(with: dataEphemeralKey, options: []) as? [String: Any] {
                    
                    let curve = ephemeralKey["crv"] as? String ?? "Unknown"
                    let keyType = ephemeralKey["kty"] as? String ?? "Unknown"
                    let x = ephemeralKey["x"] as? String ?? "Unknown"
                    let y = ephemeralKey["y"] as? String ?? "Unknown"

                    let body: ThreeDSDeviceDataBody = .init(
                        appId: appId,
                        integratorSDKVersion:  MPSDKVersion.version,
                        threeDSSDKVersion: threeDSVersion,
                        cardTokenId: cardTokenId,
                        deviceRenderOptions: .init(
                            interface: "Native", uiTypes: ["01", "02", "03", "04", "05"]
                        ),
                        encData: deviceData,
                        ephemPubKey: .init(curve: curve, keyType: keyType, x: x, y: y),
                        maxTimeout: 5,
                        protocolVersion: "2.2.0",
                        referenceNumber: referenceNumber,
                        transId: transactionID
                    )
                    
                    _ = try await repository.sendDeviceData(body)
                }
            } catch {
                throw CoreMethodsError.errorGettingEphemeralKey
            }
        }
    }
}
