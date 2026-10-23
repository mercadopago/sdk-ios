//
//  StatusScreenRepository.swift
//  MercadoPagoSDK
//

protocol StatusScreenRepository: Sendable {
    func fetchStatusScreen(
        request: StatusScreenRequestBody,
        clientToken: String,
        checkoutType: String?
    ) async throws -> StatusScreenResponse
}
