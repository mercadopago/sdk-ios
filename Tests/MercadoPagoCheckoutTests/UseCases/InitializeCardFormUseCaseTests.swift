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
        amount: Double? = nil,
        customTexts: CardFormCustomTexts? = nil
    ) -> MercadoPagoCheckout.CardFormConfiguration {
        MercadoPagoCheckout.CardFormConfiguration(amount: amount, customTexts: customTexts)
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

    // MARK: - Text Resolution (custom title)

    func testExecute_customTitle_overridesHeader() async throws {
        let sut = self.makeSUT()
        let customTexts = CardFormCustomTexts(title: "My Custom Title")
        let result = try await sut.useCase.execute(config: self.makeConfig(customTexts: customTexts))

        XCTAssertEqual(result.title, "My Custom Title")
    }

    // MARK: - Text Resolution (partial customization)

    func testExecute_partialCardNumber_overridesOnlyLabel() async throws {
        let sut = self.makeSUT()
        let customTexts = CardFormCustomTexts(cardNumber: .init(label: "Custom Card Number Label"))
        let result = try await sut.useCase.execute(config: self.makeConfig(customTexts: customTexts))
        let defaultFields = CardFormInitializationOutputStub.makeDefaultFields()

        XCTAssertEqual(result.fields.cardNumber.label, "Custom Card Number Label")
        XCTAssertEqual(result.fields.cardNumber.placeholder, defaultFields.cardNumber.placeholder)
    }

    // MARK: - Text Resolution (CVV placeholder)

    func testExecute_noCvvCustom_preservesBothPlaceholders() async throws {
        let sut = self.makeSUT()
        let result = try await sut.useCase.execute(config: self.makeConfig())
        let defaultFields = CardFormInitializationOutputStub.makeDefaultFields()

        XCTAssertEqual(result.fields.cvv.placeholderDefault, defaultFields.cvv.placeholderDefault)
        XCTAssertEqual(result.fields.cvv.placeholderAmex, defaultFields.cvv.placeholderAmex)
    }

    func testExecute_customCvvPlaceholder_overridesBoth() async throws {
        let sut = self.makeSUT()
        let customTexts = CardFormCustomTexts(cvv: .init(placeholder: "Custom CVV"))
        let result = try await sut.useCase.execute(config: self.makeConfig(customTexts: customTexts))

        XCTAssertEqual(result.fields.cvv.placeholderDefault, "Custom CVV")
        XCTAssertEqual(result.fields.cvv.placeholderAmex, "Custom CVV")
    }

    // MARK: - Text Resolution (empty custom texts = nil)

    func testExecute_emptyCustomTexts_sameAsNil() async throws {
        let sut = self.makeSUT()
        let withEmpty = try await sut.useCase.execute(config: self.makeConfig(customTexts: CardFormCustomTexts()))
        let withNil = try await sut.useCase.execute(config: self.makeConfig())

        XCTAssertEqual(withEmpty.title, withNil.title)
        XCTAssertEqual(withEmpty.fields.cardNumber.label, withNil.fields.cardNumber.label)
        XCTAssertEqual(withEmpty.fields.cardNumber.placeholder, withNil.fields.cardNumber.placeholder)
        XCTAssertEqual(withEmpty.fields.cardHolder.label, withNil.fields.cardHolder.label)
        XCTAssertEqual(withEmpty.fields.cardHolder.placeholder, withNil.fields.cardHolder.placeholder)
        XCTAssertEqual(withEmpty.fields.expiration.label, withNil.fields.expiration.label)
        XCTAssertEqual(withEmpty.fields.expiration.placeholder, withNil.fields.expiration.placeholder)
        XCTAssertEqual(withEmpty.fields.cvv.label, withNil.fields.cvv.label)
        XCTAssertEqual(withEmpty.fields.issuer.label, withNil.fields.issuer.label)
        XCTAssertEqual(withEmpty.fields.issuer.placeholder, withNil.fields.issuer.placeholder)
        XCTAssertEqual(withEmpty.fields.document.label, withNil.fields.document.label)
        XCTAssertEqual(withEmpty.fields.document.placeholder, withNil.fields.document.placeholder)
    }

    // MARK: - Text Resolution (all fields customized)

    func testExecute_allFieldsCustomized() async throws {
        let sut = self.makeSUT()
        let customTexts = CardFormCustomTexts(
            title: "CT",
            cardNumber: .init(label: "CN-L", placeholder: "CN-P"),
            cardHolder: .init(label: "CH-L", placeholder: "CH-P"),
            expiration: .init(label: "EX-L", placeholder: "EX-P"),
            cvv: .init(label: "CV-L", placeholder: "CV-P"),
            issuer: .init(label: "IS-L", placeholder: "IS-P"),
            document: .init(label: "DO-L", placeholder: "DO-P")
        )
        let result = try await sut.useCase.execute(config: self.makeConfig(customTexts: customTexts))

        XCTAssertEqual(result.title, "CT")
        XCTAssertEqual(result.fields.cardNumber.label, "CN-L")
        XCTAssertEqual(result.fields.cardNumber.placeholder, "CN-P")
        XCTAssertEqual(result.fields.cardHolder.label, "CH-L")
        XCTAssertEqual(result.fields.cardHolder.placeholder, "CH-P")
        XCTAssertEqual(result.fields.expiration.label, "EX-L")
        XCTAssertEqual(result.fields.expiration.placeholder, "EX-P")
        XCTAssertEqual(result.fields.cvv.label, "CV-L")
        XCTAssertEqual(result.fields.cvv.placeholderDefault, "CV-P")
        XCTAssertEqual(result.fields.cvv.placeholderAmex, "CV-P")
        XCTAssertEqual(result.fields.issuer.label, "IS-L")
        XCTAssertEqual(result.fields.issuer.placeholder, "IS-P")
        XCTAssertEqual(result.fields.document.label, "DO-L")
        XCTAssertEqual(result.fields.document.placeholder, "DO-P")
    }

    // MARK: - Text Resolution (validation data preserved)

    func testExecute_validationDataPreservedAfterCustomization() async throws {
        let sut = self.makeSUT()
        let customTexts = CardFormCustomTexts(title: "Custom", cardNumber: .init(label: "Custom"))
        let result = try await sut.useCase.execute(config: self.makeConfig(customTexts: customTexts))
        let defaultFields = CardFormInitializationOutputStub.makeDefaultFields()

        XCTAssertEqual(result.fields.cardNumber.validation.errorEmpty, defaultFields.cardNumber.validation.errorEmpty)
        XCTAssertEqual(result.fields.cardNumber.validation.errorInvalid, defaultFields.cardNumber.validation.errorInvalid)
        XCTAssertEqual(result.fields.cardHolder.validation.errorEmpty, defaultFields.cardHolder.validation.errorEmpty)
        XCTAssertEqual(result.fields.expiration.validation.errorEmpty, defaultFields.expiration.validation.errorEmpty)
        XCTAssertEqual(result.fields.cvv.validation.errorEmpty, defaultFields.cvv.validation.errorEmpty)
        XCTAssertEqual(result.fields.document.validation.errorEmpty, defaultFields.document.validation.errorEmpty)
    }

    // MARK: - Button Resolution

    func testExecute_withoutAmount_usesSaveButton() async throws {
        let sut = self.makeSUT()
        sut.repository.mockData = CardFormInitializationInput(
            title: "Header",
            buttonVariants: .init(save: "Guardar", pay: "Pagar"),
            fields: CardFormInitializationInputStub.makeDefaultFields(),
            identificationTypes: []
        )

        let result = try await sut.useCase.execute(config: self.makeConfig(amount: nil))

        XCTAssertEqual(result.button, "Guardar")
    }

    func testExecute_withAmount_usesPayButton() async throws {
        let sut = self.makeSUT()
        sut.repository.mockData = CardFormInitializationInput(
            title: "Header",
            buttonVariants: .init(save: "Guardar", pay: "Pagar"),
            fields: CardFormInitializationInputStub.makeDefaultFields(),
            identificationTypes: []
        )

        let result = try await sut.useCase.execute(config: self.makeConfig(amount: 100.0))

        XCTAssertEqual(result.button, "Pagar")
    }

    func testExecute_customButtonOverridesVariantResolution() async throws {
        let sut = self.makeSUT()
        sut.repository.mockData = CardFormInitializationInput(
            title: "Header",
            buttonVariants: .init(save: "Guardar", pay: "Pagar"),
            fields: CardFormInitializationInputStub.makeDefaultFields(),
            identificationTypes: []
        )
        let customTexts = CardFormCustomTexts(button: "Custom Button")

        let result = try await sut.useCase.execute(config: self.makeConfig(amount: 100.0, customTexts: customTexts))

        XCTAssertEqual(result.button, "Custom Button")
    }

    // MARK: - Error Cases

    func testExecute_repositoryFails_throws() async {
        let sut = self.makeSUT()
        sut.repository.shouldThrow = true

        do {
            _ = try await sut.useCase.execute(config: self.makeConfig())
            XCTFail("Expected repository error to propagate")
        } catch {
            XCTAssertEqual((error as NSError).domain, "test")
        }
    }
}
