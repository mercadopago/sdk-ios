//
//  FetchReviewConfirmUseCase.swift
//  MercadoPagoSDK
//

import MPCore

struct FetchReviewConfirmUseCase {
    private let repository: ReviewConfirmRepository

    init(repository: ReviewConfirmRepository = RemoteReviewConfirmRepository()) {
        self.repository = repository
    }

    func execute(
        orderId: String,
        clientToken: String,
        paymentParams: OrderTransactionParams,
        reviewConfirmConfig: ScreenConfig,
        cardDetails: ReviewConfirmCardDetails
    ) async throws(MercadoPagoCheckoutError) -> ReviewConfirmOutput {
        let requestBody = self.makeRequestBody(
            orderId: orderId,
            paymentParams: paymentParams,
            reviewConfirmConfig: reviewConfirmConfig,
            cardDetails: cardDetails
        )

        do {
            let response = try await self.repository.fetchReviewConfirm(
                request: requestBody,
                clientToken: clientToken
            )
            return ReviewConfirmOutput(from: response)
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

    // MARK: - Request building

    private func makeRequestBody(
        orderId: String,
        paymentParams: OrderTransactionParams,
        reviewConfirmConfig: ScreenConfig,
        cardDetails: ReviewConfirmCardDetails
    ) -> ReviewConfirmRequestBody {
        let seller: MPSellerInfo?
        let emailChangeEnabled: Bool
        if case let .reviewAndConfirm(configSeller, onEmailChangeRequested) = reviewConfirmConfig {
            seller = configSeller
            emailChangeEnabled = onEmailChangeRequested != nil
        } else {
            seller = nil
            emailChangeEnabled = false
        }

        let sellerInfo = seller.map {
            ReviewConfirmRequestBody.SellerInfo(name: $0.name, iconUrl: $0.logoUrl)
        }

        switch paymentParams.paymentMethodType {
        case let .card(paymentMethodId, paymentTypeId, _, installments):
            return ReviewConfirmRequestBody(
                orderId: orderId,
                paymentMethodType: paymentTypeId,
                paymentMethodId: paymentMethodId,
                issuerId: cardDetails.issuerId.map(String.init),
                bin: cardDetails.bin,
                productId: MPSDKProduct.id,
                lastFourDigits: cardDetails.lastFourDigits,
                installments: installments,
                installmentAmount: cardDetails.installmentAmount,
                emailChangeEnabled: emailChangeEnabled,
                sellerInfo: sellerInfo
            )
        case let .ticket(paymentMethodId):
            return ReviewConfirmRequestBody(
                orderId: orderId,
                paymentMethodType: "ticket",
                paymentMethodId: paymentMethodId,
                issuerId: nil,
                bin: nil,
                productId: MPSDKProduct.id,
                lastFourDigits: nil,
                installments: nil,
                installmentAmount: nil,
                emailChangeEnabled: emailChangeEnabled,
                sellerInfo: sellerInfo
            )
        }
    }
}
