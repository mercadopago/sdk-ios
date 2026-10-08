//
//  MockStatusScreenRepository.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout

final actor MockStatusScreenRepository: StatusScreenRepository {
    enum MockError: Error, Sendable {
        case resultNotSet
    }

    private var result: Result<StatusScreenResponse, Error>?
    private(set) var callCount = 0
    private(set) var lastRequest: StatusScreenRequestBody?
    private(set) var lastClientToken: String?
    private(set) var lastCheckoutType: String?

    func setResult(_ result: Result<StatusScreenResponse, Error>) {
        self.result = result
    }

    func fetchStatusScreen(
        request: StatusScreenRequestBody,
        clientToken: String,
        checkoutType: String?
    ) async throws -> StatusScreenResponse {
        self.callCount += 1
        self.lastRequest = request
        self.lastClientToken = clientToken
        self.lastCheckoutType = checkoutType
        guard let result else { throw MockError.resultNotSet }
        return try result.get()
    }
}
