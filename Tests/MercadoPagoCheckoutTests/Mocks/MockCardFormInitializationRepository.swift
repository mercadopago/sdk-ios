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
    nonisolated(unsafe) var capturedOrderId: String?
    nonisolated(unsafe) var capturedClientToken: String?

    func fetchInitialization(orderId: String?, clientToken: String?, checkoutType _: String) async throws -> CardFormInitializationInput {
        self.fetchCallCount += 1
        self.capturedOrderId = orderId
        self.capturedClientToken = clientToken
        if !self.sequentialResults.isEmpty {
            let result = self.sequentialResults.removeFirst()
            return try result.get()
        }
        if self.shouldThrow { throw NSError(domain: "test", code: -1) }
        return self.mockData ?? Self.makeDefault()
    }

    static func makeDefault(amount: Decimal? = 100) -> CardFormInitializationInput {
        CardFormInitializationInput(
            title: "Default Header",
            buttonLabel: "Save",
            currencySymbol: "R$",
            amount: amount,
            fields: CardFormInitializationInputStub.makeDefaultFields(),
            identificationTypes: []
        )
    }

    static func makeDefault(identificationTypes: [IdentificationType]) -> CardFormInitializationInput {
        CardFormInitializationInput(
            title: "Default Header",
            buttonLabel: "Save",
            currencySymbol: "R$",
            amount: 100,
            fields: CardFormInitializationInputStub.makeDefaultFields(),
            identificationTypes: identificationTypes
        )
    }
}
