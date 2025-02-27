//
//  CoreMethodsRepository.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 18/02/25.
//
import Foundation

protocol CoreMethodsRepositoryProtocol: Sendable {
    func generateCardToken(_ data: CardTokenBody) async throws -> CardTokenResponse
    func getIdentificationTypes() async throws -> [IdentificationTypesResponse]
}
