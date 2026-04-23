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

    func execute(params: CardPaymentBrickCardParams) async throws(BinFetchError) -> CardPaymentBrickCardData {
        do {
            return try await self.repository.fetchCard(params: params)
        } catch let error as BinFetchError {
            throw error
        } catch let error as APIClientError {
            if case let .apiError(response) = error {
                switch response.errorCode {
                case "PAYMENT_METHOD_NOT_FOUND":
                    throw .acceptance(.paymentMethodNotFound(response.userErrorMessage ?? String()))
                case "PAYMENT_METHOD_UNAVAILABLE":
                    throw .acceptance(.paymentMethodNotAllowed(response.userErrorMessage ?? String()))
                case "UNSUPPORTED_PAYMENT_TYPE":
                    throw .acceptance(.paymentTypeNotAllowed(response.userErrorMessage ?? String()))
                default:
                    throw .network(.init(from: error, location: .binChange))
                }
            }
            throw .network(.init(from: error, location: .binChange))
        } catch {
            throw .network(.init(code: .unknown, localizedDescription: error.localizedDescription, location: .binChange))
        }
    }
}
