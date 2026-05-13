//
//  CheckoutService.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 23/02/26.
//
import CoreMethods
import MPCore

struct CheckoutService: CheckoutServiceProtocol {
    private let coreMethods: CoreMethods

    init(coreMethods: CoreMethods = CoreMethods()) {
        self.coreMethods = coreMethods
    }

    func createCardToken(cardParams: CardParams) async throws(MercadoPagoCheckoutError) -> CardToken {
        do {
            return try await self.coreMethods.createToken(cardParams)
        } catch let error as APIClientError {
            throw MercadoPagoCheckoutError(from: error, location: .tokenization)
        } catch {
            throw MercadoPagoCheckoutError(code: .unknown, localizedDescription: error.localizedDescription, location: .tokenization)
        }
    }
}
