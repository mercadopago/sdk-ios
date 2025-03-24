//
//  IssuersUseCase.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 24/03/25.
//

protocol IssuerUseCaseProtocol: Sendable {
    func getIssuers(params: IssuersParams) async throws -> [Issuer]
}

final class IssuerUseCase: IssuerUseCaseProtocol {
    private let repository: CoreMethodsRepositoryProtocol

    init(repository: CoreMethodsRepositoryProtocol = CoreMethodsRepository()) {
        self.repository = repository
    }

    func getIssuers(params: IssuersParams) async throws -> [Issuer] {
        return try await self.repository.getIssuers(params: params)
    }
}
