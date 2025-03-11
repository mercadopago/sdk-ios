//
//  IdentificationTypeUseCase.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 25/02/25.
//

protocol IdentificationTypesUseCaseProtocol: Sendable {
    func getIdentificationTypes() async throws -> [IdentificationType]
}

final class IdentificationTypesUseCase: IdentificationTypesUseCaseProtocol {
    private let repository: CoreMethodsRepositoryProtocol

    init(repository: CoreMethodsRepositoryProtocol = CoreMethodsRepository()) {
        self.repository = repository
    }

    func getIdentificationTypes() async throws -> [IdentificationType] {
        let response = try await repository.getIdentificationTypes()

        return response.map { data in
            IdentificationType(
                id: data.id,
                name: data.name,
                type: data.type,
                minLenght: data.minLength,
                maxLenght: data.maxLength
            )
        }
    }
}
