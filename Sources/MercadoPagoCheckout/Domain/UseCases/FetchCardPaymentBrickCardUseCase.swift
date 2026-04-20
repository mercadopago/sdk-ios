//
//  FetchCardPaymentBrickCardUseCase.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 13/04/26.
//

import CoreMethods

struct FetchCardPaymentBrickCardUseCase {
    private let repository: CardPaymentBrickCardRepository

    init(repository: CardPaymentBrickCardRepository = RemoteCardPaymentBrickCardRepository()) {
        self.repository = repository
    }

    func execute(params: CardPaymentBrickCardParams) async throws(MercadoPagoCheckoutError) -> CardPaymentBrickCardData {
        do {
            return try await self.repository.fetchCard(params: params)
        } catch let error as MercadoPagoCheckoutError {
            throw error
        } catch let error as APIClientError {
            throw .init(from: error, location: .paymentMethods)
        } catch {
            throw .init(code: .unknown, localizedDescription: error.localizedDescription, location: .paymentMethods)
        }
    }
}
