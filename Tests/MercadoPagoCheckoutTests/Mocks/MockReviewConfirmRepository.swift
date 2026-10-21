//
//  MockReviewConfirmRepository.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout

final actor MockReviewConfirmRepository: ReviewConfirmRepository {
    enum MockError: Error {
        case resultNotSet
    }

    private var result: Result<ReviewConfirmResponse, Error>?
    private(set) var callCount = 0
    private(set) var lastRequest: ReviewConfirmRequestBody?
    private(set) var lastClientToken: String?
    private(set) var lastCheckoutType: String?

    func setResult(_ result: Result<ReviewConfirmResponse, Error>) {
        self.result = result
    }

    func fetchReviewConfirm(
        request: ReviewConfirmRequestBody,
        clientToken: String,
        checkoutType: String
    ) async throws -> ReviewConfirmResponse {
        self.callCount += 1
        self.lastRequest = request
        self.lastClientToken = clientToken
        self.lastCheckoutType = checkoutType
        guard let result else { throw MockError.resultNotSet }
        return try result.get()
    }
}
