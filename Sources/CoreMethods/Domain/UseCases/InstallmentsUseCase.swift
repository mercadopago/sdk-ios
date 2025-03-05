//
//  InstallmentsUseCase.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 28/02/25.
//

protocol InstallmentsUseCaseProtocol: Sendable {
    func getInstallments(params: InstallmentsParams) async throws -> [Installment]
}

final class InstallmentsUseCase: InstallmentsUseCaseProtocol {
    private let repository: CoreMethodsRepositoryProtocol

    init(repository: CoreMethodsRepositoryProtocol = CoreMethodsRepository()) {
        self.repository = repository
    }

    func getInstallments(params: InstallmentsParams) async throws -> [Installment] {
        return try await self.repository.getInstallments(params: params)
    }
}
