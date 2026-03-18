//
//  InitializeCardFormUseCaseTests.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 16/03/26.
//

@testable import CoreMethods
@testable import MercadoPagoCheckout
import XCTest

final class InitializeCardFormUseCaseTests: XCTestCase {
    // MARK: - Types

    typealias SUT = (
        useCase: InitializeCardFormUseCase,
        repository: MockCardFormInitializationRepository
    )

    // MARK: - Stubs

    private static let stubIdentificationType = IdentificationType(
        id: "CPF",
        name: "CPF",
        type: "number",
        minLenght: 11,
        maxLenght: 11
    )

    // MARK: - Helpers

    private func makeSUT() -> SUT {
        let repository = MockCardFormInitializationRepository()
        let useCase = InitializeCardFormUseCase(repository: repository)
        return (useCase, repository)
    }

    private func makeConfig(
        amount: Double? = nil
    ) -> MercadoPagoCheckout.CardFormConfiguration {
        MercadoPagoCheckout.CardFormConfiguration(amount: amount)
    }

    // MARK: - Success Cases

    func testExecute_returnsInitResultAndTypes() async throws {
        let sut = self.makeSUT()
        sut.repository.mockData = MockCardFormInitializationRepository.makeDefault(
            identificationTypes: [Self.stubIdentificationType]
        )

        let result = try await sut.useCase.execute(config: self.makeConfig())

        XCTAssertEqual(result.identificationTypes.count, 1)
        XCTAssertEqual(result.identificationTypes.first?.id, "CPF")
        XCTAssertEqual(result.title, "Default Header")
        XCTAssertEqual(result.button, "Save")
    }

    // MARK: - Text Resolution (no customization)

    func testExecute_noCustomization_returnsDefaults() async throws {
        let sut = self.makeSUT()
        let result = try await sut.useCase.execute(config: self.makeConfig())
        let defaultFields = CardFormInitializationOutputStub.makeDefaultFields()

        XCTAssertEqual(result.title, "Default Header")
        XCTAssertEqual(result.fields.cardNumber.label, defaultFields.cardNumber.label)
        XCTAssertEqual(result.fields.cardNumber.placeholder, defaultFields.cardNumber.placeholder)
        XCTAssertEqual(result.fields.cardHolder.label, defaultFields.cardHolder.label)
        XCTAssertEqual(result.fields.cardHolder.placeholder, defaultFields.cardHolder.placeholder)
        XCTAssertEqual(result.fields.cardHolder.helperText, defaultFields.cardHolder.helperText)
        XCTAssertEqual(result.fields.expiration.label, defaultFields.expiration.label)
        XCTAssertEqual(result.fields.expiration.placeholder, defaultFields.expiration.placeholder)
        XCTAssertEqual(result.fields.cvv.label, defaultFields.cvv.label)
        XCTAssertEqual(result.fields.issuer.label, defaultFields.issuer.label)
        XCTAssertEqual(result.fields.issuer.placeholder, defaultFields.issuer.placeholder)
        XCTAssertEqual(result.fields.document.label, defaultFields.document.label)
        XCTAssertEqual(result.fields.document.placeholder, defaultFields.document.placeholder)
    }

    // MARK: - CVV placeholders

    func testExecute_noCvvCustom_preservesBothPlaceholders() async throws {
        let sut = self.makeSUT()
        let result = try await sut.useCase.execute(config: self.makeConfig())
        let defaultFields = CardFormInitializationOutputStub.makeDefaultFields()

        XCTAssertEqual(result.fields.cvv.placeholderDefault, defaultFields.cvv.placeholderDefault)
        XCTAssertEqual(result.fields.cvv.placeholderAmex, defaultFields.cvv.placeholderAmex)
    }

    // MARK: - Button Resolution

    func testExecute_usesSaveButton() async throws {
        let sut = self.makeSUT()
        sut.repository.mockData = CardFormInitializationInput(
            title: "Header",
            buttonVariants: .init(save: "Guardar", pay: "Pagar"),
            fields: CardFormInitializationInputStub.makeDefaultFields(),
            identificationTypes: []
        )

        let result = try await sut.useCase.execute(config: self.makeConfig())

        XCTAssertEqual(result.button, "Guardar")
    }

    // MARK: - Error Cases

    func testExecute_repositoryFails_throws() async {
        let sut = self.makeSUT()
        sut.repository.shouldThrow = true

        do {
            _ = try await sut.useCase.execute(config: self.makeConfig())
            XCTFail("Expected repository error to propagate")
        } catch let error as MercadoPagoCheckoutError {
            XCTAssertEqual(error.code, .unknown)
        } catch {
            XCTFail("Expected MercadoPagoCheckoutError, got \(error)")
        }
    }
}
