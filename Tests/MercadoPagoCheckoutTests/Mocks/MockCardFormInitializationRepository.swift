//
//  MockCardFormInitializationRepository.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 16/03/26.
//

import CoreMethods
import Foundation
@testable import MercadoPagoCheckout

final class MockCardFormInitializationRepository: CardFormInitializationRepository {
    nonisolated(unsafe) var mockData: CardFormInitializationInput?
    nonisolated(unsafe) var shouldThrow = false

    func fetchInitialization() async throws -> CardFormInitializationInput {
        if self.shouldThrow { throw NSError(domain: "test", code: -1) }
        return self.mockData ?? Self.makeDefault()
    }

    static func makeDefault() -> CardFormInitializationInput {
        CardFormInitializationInput(
            title: "Default Header",
            buttonVariants: .init(save: "Save", pay: ""),
            fields: CardFormInitializationInputStub.makeDefaultFields(),
            identificationTypes: []
        )
    }

    static func makeDefault(identificationTypes: [IdentificationType]) -> CardFormInitializationInput {
        CardFormInitializationInput(
            title: "Default Header",
            buttonVariants: .init(save: "Save", pay: ""),
            fields: CardFormInitializationInputStub.makeDefaultFields(),
            identificationTypes: identificationTypes
        )
    }
}
