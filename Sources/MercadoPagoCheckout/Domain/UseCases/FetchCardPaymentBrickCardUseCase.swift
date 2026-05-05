//
//  FetchCardPaymentBrickCardUseCase.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 13/04/26.
//

import CoreMethods
import MPCore

struct FetchCardPaymentBrickCardUseCase {
    private let repository: CardPaymentBrickCardRepository

    init(repository: CardPaymentBrickCardRepository = RemoteCardPaymentBrickCardRepository()) {
        self.repository = repository
    }

    func execute(params: CardPaymentBrickCardParams) async throws(MercadoPagoCheckoutError) -> CardPaymentBrickCardData {
        do {
            let data = try await self.repository.fetchCard(params: params)
            if data.paymentMethods.isEmpty {
                throw MercadoPagoCheckoutError(
                    code: .serviceError,
                    localizedDescription: "",
                    location: .binChange,
                    serviceError: APIErrorResponse(
                        code: "",
                        message: "",
                        errorCode: CheckoutAPIErrorCode.Acceptance.emptyPaymentMethods.rawValue
                    )
                )
            }
            return data
        } catch let error as MercadoPagoCheckoutError {
            throw error
        } catch let error as APIClientError {
            throw MercadoPagoCheckoutError(from: error, location: .binChange)
        } catch {
            throw MercadoPagoCheckoutError(code: .unknown, localizedDescription: error.localizedDescription, location: .binChange)
        }
    }
}
