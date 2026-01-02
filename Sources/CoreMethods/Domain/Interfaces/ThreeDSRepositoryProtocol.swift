//
//  ThreeDSRepositoryProtocol.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 02/01/26.
//

protocol ThreeDSRepositoryProtocol: Sendable {
    func postSDKData(_ data: MPThreeDSAuthRequestParametersBody) async throws -> MPThreeDSResponse
}

