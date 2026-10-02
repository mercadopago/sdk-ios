//
//  FetchPaymentBrickInitializationUseCase.swift
//  MercadoPagoSDK
//

import Foundation
import MPCore

struct FetchPaymentBrickInitializationUseCase {
    private let repository: PaymentBrickRepository

    init(repository: PaymentBrickRepository = RemotePaymentBrickRepository()) {
        self.repository = repository
    }

    func execute(
        orderId: String,
        clientToken: String,
        screens: String? = nil
    ) async throws(MercadoPagoCheckoutError) -> PaymentInitializationOutput {
        do {
            return try await self.repository.fetchInitialization(
                orderId: orderId,
                clientToken: clientToken,
                screens: screens
            )
        } catch let error as APIClientError {
            throw MercadoPagoCheckoutError(from: error, location: .initialization)
        } catch {
            throw MercadoPagoCheckoutError(
                code: .unknown,
                localizedDescription: error.localizedDescription,
                userInfo: ["error": error],
                location: .initialization
            )
        }
    }
}
