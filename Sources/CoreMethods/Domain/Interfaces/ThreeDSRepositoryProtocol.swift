//
//  ThreeDSRepositoryProtocol.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 02/01/26.
//

import Foundation

protocol ThreeDSRepositoryProtocol: Sendable {
    func postSDKData(_ data: MPThreeDSAuthRequestParametersBody) async throws -> ThreeDSDeviceDataResponse
    func getChallenge(_ id: String ) async throws -> MPThreeDSChallengeResponse
    
    func patchChallenge(_ id: String, body: MPThreeDSUpdateStatusBody) async throws -> Data
}

