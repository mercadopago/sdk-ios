//
//  PaymentMethodUseCase.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 07/03/25.
//

protocol PaymentMethodUseCaseProtocol: Sendable {
    func getPayment(params: PaymentMethodsParams) async throws -> [PaymentMethod]
}

final class PaymentMethodUseCase: PaymentMethodUseCaseProtocol {
    private let repository: CoreMethodsRepositoryProtocol

    init(repository: CoreMethodsRepositoryProtocol = CoreMethodsRepository()) {
        self.repository = repository
    }

    func getPayment(params: PaymentMethodsParams) async throws -> [PaymentMethod] {
        return try await self.repository.getPaymentMethods(params: params)
    }
}
