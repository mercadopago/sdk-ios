//
//  ReviewConfirmRepository.swift
//  MercadoPagoSDK
//

/// Abstraction for fetching the review and confirm screen's data from the backend.
protocol ReviewConfirmRepository: Sendable {
    func fetchReviewConfirm(
        request: ReviewConfirmRequestBody,
        clientToken: String,
        checkoutType: String
    ) async throws -> ReviewConfirmResponse
}
