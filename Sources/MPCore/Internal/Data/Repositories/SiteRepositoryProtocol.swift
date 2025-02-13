//
//  SiteRepositoryProtocol.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 12/02/25.
//

protocol SiteRepositoryProtocol: Sendable {
    func getID() async throws -> SiteResponse
}
