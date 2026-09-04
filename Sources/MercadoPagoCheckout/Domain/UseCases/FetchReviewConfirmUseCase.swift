//
//  FetchReviewConfirmUseCase.swift
//  MercadoPagoSDK
//

import Foundation
import MPCore

struct FetchReviewConfirmUseCase {
    private let repository: ReviewConfirmRepository

    init(repository: ReviewConfirmRepository = RemoteReviewConfirmRepository()) {
        self.repository = repository
    }

    func execute(
        orderId: String,
        clientToken: String,
        checkoutType: String,
        paymentParams: OrderTransactionParams,
        reviewConfirmConfig: ScreenConfig,
        sellerInfo: MPSellerInfo?,
        cardDetails: ReviewConfirmCardDetails
    ) async throws(MercadoPagoCheckoutError) -> ReviewConfirmOutput {
        let requestBody = self.makeRequestBody(
            orderId: orderId,
            paymentParams: paymentParams,
            reviewConfirmConfig: reviewConfirmConfig,
            sellerInfo: sellerInfo,
            cardDetails: cardDetails
        )

        do {
            let response = try await self.repository.fetchReviewConfirm(
                request: requestBody,
                clientToken: clientToken,
                checkoutType: checkoutType
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
        sellerInfo: MPSellerInfo?,
        cardDetails: ReviewConfirmCardDetails
    ) -> ReviewConfirmRequestBody {
        let emailChangeEnabled: Bool
        if case let .reviewAndConfirm(onEmailChangeRequested) = reviewConfirmConfig {
            emailChangeEnabled = onEmailChangeRequested != nil
        } else {
            emailChangeEnabled = false
        }

        let sellerInfo = sellerInfo.map {
            ReviewConfirmRequestBody.SellerInfo(name: $0.name, iconUrl: $0.logoUrl)
        }

        switch paymentParams.paymentMethodType {
        case let .card(paymentMethodId, paymentTypeId, _, _):
            return ReviewConfirmRequestBody(
                orderId: orderId,
                paymentMethodType: paymentTypeId,
                paymentMethodId: paymentMethodId,
                issuerId: cardDetails.issuerId.map(String.init),
                bin: cardDetails.bin,
                lastFourDigits: cardDetails.lastFourDigits,
                installments: cardDetails.installments,
                installmentAmount: cardDetails.installments == nil ? nil : self.requestAmount(from: cardDetails.installmentAmount),
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
                lastFourDigits: nil,
                installments: nil,
                installmentAmount: nil,
                emailChangeEnabled: emailChangeEnabled,
                sellerInfo: sellerInfo
            )
        }
    }

    private func requestAmount(from amount: Decimal?) -> String? {
        guard let amount else { return nil }

        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        return formatter.string(from: amount as NSDecimalNumber) ?? NSDecimalNumber(decimal: amount).stringValue
    }
}
