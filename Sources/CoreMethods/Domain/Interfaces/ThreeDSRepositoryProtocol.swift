//
//  ThreeDSRepositoryProtocol.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 02/01/26.
//

protocol ThreeDSRepositoryProtocol: Sendable {
    func sendDeviceData(_ data: ThreeDSDeviceDataBody) async throws -> ThreeDSDeviceDataResponse
}
