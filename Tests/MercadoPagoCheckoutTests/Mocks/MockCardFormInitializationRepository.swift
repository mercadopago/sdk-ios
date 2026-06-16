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
    nonisolated(unsafe) var fetchCallCount = 0
    nonisolated(unsafe) var sequentialResults: [Result<CardFormInitializationInput, Error>] = []

    func fetchInitialization(amount _: Double?, checkoutType _: String) async throws -> CardFormInitializationInput {
        self.fetchCallCount += 1
        if !self.sequentialResults.isEmpty {
            let result = self.sequentialResults.removeFirst()
            return try result.get()
        }
        if self.shouldThrow { throw NSError(domain: "test", code: -1) }
        return self.mockData ?? Self.makeDefault()
    }

    static func makeDefault() -> CardFormInitializationInput {
        CardFormInitializationInput(
            title: "Default Header",
            buttonLabel: "Save",
            currencySymbol: "R$",
            fields: CardFormInitializationInputStub.makeDefaultFields(),
            identificationTypes: []
        )
    }

    static func makeDefault(identificationTypes: [IdentificationType]) -> CardFormInitializationInput {
        CardFormInitializationInput(
            title: "Default Header",
            buttonLabel: "Save",
            currencySymbol: "R$",
            fields: CardFormInitializationInputStub.makeDefaultFields(),
            identificationTypes: identificationTypes
        )
    }
}
