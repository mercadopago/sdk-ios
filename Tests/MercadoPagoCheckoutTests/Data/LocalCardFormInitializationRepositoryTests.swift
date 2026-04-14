//
//  LocalCardFormInitializationRepositoryTests.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 16/03/26.
//

@testable import CoreMethods
@testable import MercadoPagoCheckout
@testable import MPFoundation
import XCTest

final class LocalCardFormInitializationRepositoryTests: XCTestCase {
    // MARK: - Helpers

    private func makeSUT() async -> (repository: LocalCardFormInitializationRepository, service: MockCheckoutService) {
        let service = MockCheckoutService()
        await service.setIdentificationTypesResult(.success([]))
        let repository = LocalCardFormInitializationRepository(service: service)
        return (repository, service)
    }

    // MARK: - Tests

    func testFetchReturnsAllFields() async throws {
        // Arrange
        let sut = await makeSUT()

        // Act
        let data = try await sut.repository.fetchInitialization(amount: nil, checkoutType: "card_form")

        // Assert
        XCTAssertFalse(data.title.isEmpty)
        XCTAssertFalse(data.buttonLabel.isEmpty)
        XCTAssertFalse(data.fields.cardNumber.label.isEmpty)
        XCTAssertFalse(data.fields.cardNumber.placeholder.isEmpty)
        XCTAssertFalse(data.fields.cardHolder.label.isEmpty)
        XCTAssertFalse(data.fields.cardHolder.placeholder.isEmpty)
        XCTAssertFalse(data.fields.expiration.label.isEmpty)
        XCTAssertFalse(data.fields.expiration.placeholder.isEmpty)
        XCTAssertFalse(data.fields.cvv.label.isEmpty)
        XCTAssertFalse(data.fields.cvv.placeholderDefault.isEmpty)
        XCTAssertFalse(data.fields.cvv.placeholderAmex.isEmpty)
        XCTAssertFalse(data.fields.issuer.label.isEmpty)
        XCTAssertFalse(data.fields.issuer.placeholder.isEmpty)
        XCTAssertFalse(data.fields.document.label.isEmpty)
        XCTAssertFalse(data.fields.document.placeholder.isEmpty)
    }

    func testTitleMatchesMPStrings() async throws {
        // Arrange
        let sut = await makeSUT()

        // Act
        let data = try await sut.repository.fetchInitialization(amount: nil, checkoutType: "card_form")

        // Assert
        XCTAssertEqual(data.title, MPStrings.CardForm.title)
    }

    func testButtonLabelExists() async throws {
        // Arrange
        let sut = await makeSUT()

        // Act
        let data = try await sut.repository.fetchInitialization(amount: nil, checkoutType: "card_form")

        // Assert
        XCTAssertFalse(data.buttonLabel.isEmpty)
    }

    func testCardNumberLabelsMatchMPStrings() async throws {
        // Arrange
        let sut = await makeSUT()

        // Act
        let data = try await sut.repository.fetchInitialization(amount: nil, checkoutType: "card_form")

        // Assert
        XCTAssertEqual(data.fields.cardNumber.label, MPStrings.CardForm.CardNumber.label)
        XCTAssertEqual(data.fields.cardNumber.placeholder, MPStrings.CardForm.CardNumber.placeholder)
    }

    func testValidationTexts_cardNumber() async throws {
        // Arrange
        let sut = await makeSUT()

        // Act
        let data = try await sut.repository.fetchInitialization(amount: nil, checkoutType: "card_form")
        let validation = data.fields.cardNumber.validation

        // Assert
        XCTAssertEqual(validation.errorEmpty, MPStrings.CardForm.CardNumber.errorEmpty)
        XCTAssertEqual(validation.errorIncomplete, MPStrings.CardForm.CardNumber.errorIncomplete)
        XCTAssertEqual(validation.errorInvalid, MPStrings.CardForm.CardNumber.errorInvalid)
    }

    func testFetchReturnsIdentificationTypes() async throws {
        // Arrange
        let service = MockCheckoutService()
        let expectedType = IdentificationType(id: "CPF", name: "CPF", type: "number", minLength: 11, maxLength: 11)
        await service.setIdentificationTypesResult(.success([expectedType]))
        let repository = LocalCardFormInitializationRepository(service: service)

        // Act
        let data = try await repository.fetchInitialization(amount: nil, checkoutType: "card_form")

        // Assert
        XCTAssertEqual(data.identificationTypes.count, 1)
        XCTAssertEqual(data.identificationTypes.first?.id, "CPF")
    }

    func testFetchPropagatesServiceError() async {
        // Arrange
        let service = MockCheckoutService()
        await service.setIdentificationTypesResult(.failure(MockCheckoutService.MockError.resultNotSet))
        let repository = LocalCardFormInitializationRepository(service: service)

        // Act & Assert
        do {
            _ = try await repository.fetchInitialization(amount: nil, checkoutType: "card_form")
            XCTFail("Expected error to propagate")
        } catch {
            XCTAssertTrue(error is MercadoPagoCheckoutError)
        }
    }
}
