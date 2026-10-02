//
//  PaymentBrickRepository.swift
//  MercadoPagoSDK
//
//  Created by SDK on 22/06/26.
//
import Foundation

/// Abstraction for fetching payment brick initialization data.
protocol PaymentBrickRepository: Sendable {
    func fetchInitialization(
        orderId: String,
        clientToken: String,
        screens: String?
    ) async throws -> PaymentInitializationOutput
}
