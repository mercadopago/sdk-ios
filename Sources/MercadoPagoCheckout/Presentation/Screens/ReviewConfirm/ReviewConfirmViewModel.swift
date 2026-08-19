//
//  ReviewConfirmViewModel.swift
//  MercadoPagoSDK
//

import Foundation
import MPComponents

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
    private let paymentParams: OrderTransactionParams
    private let reviewConfirmConfig: ScreenConfig
    private let cardDetails: ReviewConfirmCardDetails

    private var loadTask: Task<Void, Never>?

    init(
        fetchReviewConfirmUseCase: FetchReviewConfirmUseCase = FetchReviewConfirmUseCase(),
        orderTransactionUseCase: OrderTransactionUseCase = OrderTransactionUseCase(),
        order: MPOrder,
        paymentParams: OrderTransactionParams,
        reviewConfirmConfig: ScreenConfig,
        cardDetails: ReviewConfirmCardDetails
    ) {
        self.fetchReviewConfirmUseCase = fetchReviewConfirmUseCase
        self.orderTransactionUseCase = orderTransactionUseCase
        self.order = order
        self.paymentParams = paymentParams
        self.reviewConfirmConfig = reviewConfirmConfig
        self.cardDetails = cardDetails
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
            let output = try await self.fetchReviewConfirmUseCase.execute(
                orderId: self.order.orderId,
                clientToken: self.order.clientToken,
                paymentParams: self.paymentParams,
                reviewConfirmConfig: self.reviewConfirmConfig,
                cardDetails: self.cardDetails
            )
            guard !Task.isCancelled else { return }
            self.screenState = .success(output)
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
        try await self.orderTransactionUseCase.execute(
            orderId: self.order.orderId,
            clientToken: self.order.clientToken,
            params: self.paymentParams
        )
    }

    func modifyPaymentMethod() {
        // TODO: Track the review_confirm_payment_method_changed Melidata event here (I18).
    }

    func modifyEmail() {
        // TODO: Track the review_confirm_payer_field_changed Melidata event here (I18).
    }

    func goBack() {
        // TODO: Track the review_confirm_back Melidata event here (I18).
    }
}
