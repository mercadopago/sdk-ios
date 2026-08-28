//
//  ReviewConfirmViewModel.swift
//  MercadoPagoSDK
//

import Foundation
import MPAnalytics
import MPComponents
import MPCore

/// Drives the review and confirm screen: it holds the formatted `screenState` and performs the
/// backend work, returning results to the screen. Following the other checkout screens
/// (SecurityCode, MethodSelection, …), navigation and seller-facing outcomes stay on the screen —
/// the view model does not hold outcome callbacks.
@MainActor
final class ReviewConfirmViewModel: ObservableObject {
    @Published private(set) var screenState: ReviewConfirmScreenState = .loading

    // MARK: - Dependencies

    private let fetchReviewConfirmUseCase: FetchReviewConfirmUseCase
    private let orderTransactionUseCase: OrderTransactionUseCase

    // MARK: - Input

    private let order: MPOrder
    private let checkoutType: String
    private let paymentParams: OrderTransactionParams
    private let reviewConfirmConfig: ScreenConfig
    private let sellerInfo: MPSellerInfo?
    private let cardDetails: ReviewConfirmCardDetails
    private let analytics: AnalyticsInterface

    private var loadTask: Task<Void, Never>?
    private var analyticsTask: Task<Void, Never>?

    init(
        fetchReviewConfirmUseCase: FetchReviewConfirmUseCase = FetchReviewConfirmUseCase(),
        orderTransactionUseCase: OrderTransactionUseCase = OrderTransactionUseCase(),
        order: MPOrder,
        checkoutType: String,
        paymentParams: OrderTransactionParams,
        reviewConfirmConfig: ScreenConfig,
        sellerInfo: MPSellerInfo?,
        cardDetails: ReviewConfirmCardDetails,
        analytics: AnalyticsInterface = CoreDependencyContainer.shared.analytics
    ) {
        self.fetchReviewConfirmUseCase = fetchReviewConfirmUseCase
        self.orderTransactionUseCase = orderTransactionUseCase
        self.order = order
        self.checkoutType = checkoutType
        self.paymentParams = paymentParams
        self.reviewConfirmConfig = reviewConfirmConfig
        self.sellerInfo = sellerInfo
        self.cardDetails = cardDetails
        self.analytics = analytics
    }

    // MARK: - Load

    /// Fetches the screen contents from the backend and publishes the result via `screenState`.
    ///
    /// A concurrent call (e.g. SwiftUI re-running `.task`) cancels the in-flight fetch, so only the
    /// latest one writes `screenState` — a late failure never overwrites a newer success.
    func load() async {
        self.loadTask?.cancel()
        let task = Task { [weak self] in
            guard let self else { return }
            await self.performLoad()
        }
        self.loadTask = task
        await task.value
    }

    private func performLoad() async {
        self.screenState = .loading
        do {
            let output = try await fetchReviewConfirmUseCase.execute(
                orderId: self.order.orderId,
                clientToken: self.order.clientToken,
                checkoutType: self.checkoutType,
                paymentParams: self.paymentParams,
                reviewConfirmConfig: self.reviewConfirmConfig,
                sellerInfo: self.sellerInfo,
                cardDetails: self.cardDetails
            )
            guard !Task.isCancelled else { return }
            self.screenState = .success(output)
            trackInitialize(transactionAmount: output.footer.totalAmount)
        } catch {
            guard !Task.isCancelled else { return }
            self.screenState = .error(error)
        }
    }

    // MARK: - Installments

    func installmentsSubtitleData(
        _ installments: ReviewConfirmFooter.Installments?
    ) -> MPFooterSubtitleData? {
        guard let installments else { return nil }

        var segments = [
            MPFooterSubtitleData.Segment(text: installments.label)
        ]
        if let secondaryLabel = installments.secondaryLabel, !secondaryLabel.isEmpty {
            segments.append(
                .init(
                    text: secondaryLabel,
                    color: installments.state == "success" ? .feedbackPositive : .secondary
                )
            )
        }
        return .init(segments: segments)
    }

    // MARK: - Actions

    /// Processes the order, returning the result to the screen. Throws on failure so the screen can
    /// route it to the seller's `onError`.
    func confirm() async throws(MercadoPagoCheckoutError) -> OrderTransactionProcessData {
        trackContinue()
        return try await self.orderTransactionUseCase.execute(
            orderId: self.order.orderId,
            clientToken: self.order.clientToken,
            params: self.paymentParams
        )
    }

    func modifyPaymentMethod() {
        trackPaymentMethodChanged()
    }

    func modifyEmail() {
        enqueueAnalytics { [analytics = self.analytics] in
            await analytics.trackEvent(ReviewConfirmAnalyticsPath.payerFieldChanged)
                .setEventData(ReviewConfirmPayerFieldChangedEventData(changedField: "email"))
                .send()
        }
    }

    func goBack() {
        enqueueAnalytics { [analytics = self.analytics] in
            await analytics.trackEvent(ReviewConfirmAnalyticsPath.back).send()
        }
    }
}

// MARK: - Analytics

private extension ReviewConfirmViewModel {
    func trackInitialize(transactionAmount: Decimal) {
        let eventData = self.paymentMethodEventData(transactionAmount: transactionAmount)
        self.enqueueAnalytics { [analytics = self.analytics] in
            await analytics.trackView(ReviewConfirmAnalyticsPath.initialize)
                .setEventData(eventData)
                .send()
        }
    }

    func trackContinue() {
        self.enqueueAnalytics { [analytics = self.analytics] in
            await analytics.trackEvent(ReviewConfirmAnalyticsPath.continuePayment).send()
        }
    }

    func trackPaymentMethodChanged() {
        let eventData = self.paymentMethodEventData(transactionAmount: self.reviewedTransactionAmount)
        self.enqueueAnalytics { [analytics = self.analytics] in
            await analytics.trackEvent(ReviewConfirmAnalyticsPath.paymentMethodChanged)
                .setEventData(eventData)
                .send()
        }
    }

    var reviewedTransactionAmount: Decimal {
        guard case let .success(output) = screenState else {
            return self.paymentParams.amount
        }
        return output.footer.totalAmount
    }

    func paymentMethodEventData(transactionAmount: Decimal) -> ReviewConfirmPaymentMethodEventData {
        switch self.paymentParams.paymentMethodType {
        case let .card(paymentMethodId, paymentTypeId, _, installments):
            ReviewConfirmPaymentMethodEventData(
                type: paymentTypeId,
                paymentMethodId: paymentMethodId,
                paymentTypeId: paymentTypeId,
                issuerId: self.cardDetails.issuerId.map(String.init) ?? MPAnalytics.dataNotApply,
                cardId: self.cardDetails.cardId ?? MPAnalytics.dataNotApply,
                transactionAmount: transactionAmount,
                installments: installments
            )
        case let .ticket(paymentMethodId):
            ReviewConfirmPaymentMethodEventData(
                type: "ticket",
                paymentMethodId: paymentMethodId,
                paymentTypeId: "ticket",
                issuerId: MPAnalytics.dataNotApply,
                cardId: MPAnalytics.dataNotApply,
                transactionAmount: transactionAmount,
                installments: 0
            )
        }
    }

    func enqueueAnalytics(_ block: @escaping @Sendable () async -> Void) {
        let previous = self.analyticsTask
        self.analyticsTask = Task {
            await previous?.value
            await block()
        }
    }
}
