//
//  CardFormInitializationRepository.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 16/03/26.
//

/// Abstraction for fetching card form initialization data.
/// Current implementation is local (MPStrings + service). Future: remote endpoint.
protocol CardFormInitializationRepository: Sendable {
    func fetchInitialization() async throws -> CardFormInitializationInput
}
