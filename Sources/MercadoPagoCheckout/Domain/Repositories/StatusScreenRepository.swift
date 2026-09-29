//
//  StatusScreenRepository.swift
//  MercadoPagoSDK
//

protocol StatusScreenRepository: Sendable {
    func fetchStatusScreen(
        request: StatusScreenRequestBody,
        clientToken: String
    ) async throws -> StatusScreenResponse
}
