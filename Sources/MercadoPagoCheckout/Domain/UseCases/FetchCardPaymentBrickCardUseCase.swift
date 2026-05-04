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
            let data = try await self.repository.fetchCard(params: params)
            if data.paymentMethods.isEmpty {
                throw BinFetchError.acceptance(.paymentMethodNotFound)
            }
            return data
        } catch let error as BinFetchError {
            throw error
        } catch let error as APIClientError {
            if case let .apiError(response) = error {
                switch response.errorCode.flatMap(CheckoutAPIErrorCode.Acceptance.init) {
                case .emptyPaymentMethods:
                    throw .acceptance(.paymentMethodNotFound)
                case .paymentMethodUnavailable:
                    throw .acceptance(.paymentMethodNotAllowed(response.userErrorMessage ?? String()))
                case nil:
                    throw .network(.init(from: error, location: .binChange))
                }
            }
            throw .network(.init(from: error, location: .binChange))
        } catch let error as MercadoPagoCheckoutError {
            throw .network(error)
        } catch {
            throw .network(.init(code: .unknown, localizedDescription: error.localizedDescription, location: .binChange))
        }
    }
}
