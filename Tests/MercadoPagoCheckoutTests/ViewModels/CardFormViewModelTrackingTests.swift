//
//  CardFormViewModelTrackingTests.swift
//  MercadoPagoSDK
//

import CommonTests
@testable import CoreMethods
@testable import MercadoPagoCheckout
import XCTest

@MainActor
final class CardFormViewModelTrackingTests: XCTestCase {
    // MARK: - Types

    typealias SUT = (
        viewModel: CardFormViewModel,
        service: MockCheckoutService,
        analytics: MockAnalytics
    )

    // MARK: - Helpers

    private func makeSUT(
        identificationTypes: [IdentificationType] = []
    ) -> SUT {
        let service = MockCheckoutService()
        let analytics = MockAnalytics()
        let configuration = MercadoPagoCheckout.CheckoutConfiguration(
            type: .cardForm(cardFormConfiguration: .init()),
            paymentMethod: [.card(allowedTypes: [.credit, .debit, .prepaid])]
        )
        let initResult = CardFormInitializationOutputStub.make(identificationTypes: identificationTypes)
        let viewModel = CardFormViewModel(
            configuration: configuration,
            initResult: initResult,
            service: service,
            analytics: analytics
        )
        return (viewModel, service, analytics)
    }

    // MARK: - trackInputValidation

    func test_trackInputValidation_cardNumber_valid_shouldTrackCorrectEvent() async {
        // Arrange
        let sut = self.makeSUT()

        // Act
        sut.viewModel.trackInputValidation(field: .cardNumber, isValid: true)
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.track(path: CardFormAnalyticsPath.inputValidation)))
        XCTAssertTrue(messages.contains(.setEventData(["field": "card_number", "is_input_valid": true])))
        XCTAssertTrue(messages.contains(.send))
    }

    func test_trackInputValidation_cardHolder_invalid_shouldTrackIsInputValidFalse() async {
        // Arrange
        let sut = self.makeSUT()

        // Act
        sut.viewModel.trackInputValidation(field: .cardHolder, isValid: false)
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.setEventData(["field": "card_holder", "is_input_valid": false])))
    }

    func test_trackInputValidation_expirationDate_shouldTrackCorrectField() async {
        // Arrange
        let sut = self.makeSUT()

        // Act
        sut.viewModel.trackInputValidation(field: .expirationDate, isValid: true)
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.setEventData(["field": "expiration_date", "is_input_valid": true])))
    }

    func test_trackInputValidation_securityCode_shouldTrackCvvField() async {
        // Arrange
        let sut = self.makeSUT()

        // Act
        sut.viewModel.trackInputValidation(field: .securityCode, isValid: true)
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.setEventData(["field": "cvv", "is_input_valid": true])))
    }

    func test_trackInputValidation_document_shouldTrackDocumentField() async {
        // Arrange
        let sut = self.makeSUT()

        // Act
        sut.viewModel.trackInputValidation(field: .document, isValid: false)
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.setEventData(["field": "document", "is_input_valid": false])))
    }

    // MARK: - trackUserCanceled

    func test_trackUserCanceled_shouldTrackUserCanceledErrorEvent() async {
        // Arrange
        let sut = self.makeSUT()

        // Act
        sut.viewModel.trackUserCanceled(context: CardFormUserCancelledContext(fields: []))
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.track(path: CardFormAnalyticsPath.userCanceledError)))
        XCTAssertTrue(messages.contains(.send))
    }

    func test_trackUserCanceled_shouldSendEmptyErrorType() async {
        // Arrange
        let sut = self.makeSUT()

        // Act
        sut.viewModel.trackUserCanceled(context: CardFormUserCancelledContext(fields: []))
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.setEventData(["error_type": ""])))
    }

    // MARK: - trackDropdownSelection (via selectTypeDocument didSet)

    func test_selectTypeDocument_onChange_shouldTrackDropdownSelectionEvent() async {
        // Arrange
        let cpf = IdentificationType(
            id: "CPF",
            name: "CPF",
            type: "numeric",
            minLenght: 11,
            maxLenght: 11
        )
        let cnpj = IdentificationType(
            id: "CNPJ",
            name: "CNPJ",
            type: "numeric",
            minLenght: 14,
            maxLenght: 14
        )
        let sut = self.makeSUT(identificationTypes: [cpf, cnpj])

        // Act — change document type triggers trackDropdownSelection
        sut.viewModel.selectTypeDocument = cnpj
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.track(path: CardFormAnalyticsPath.dropdownSelection)))
        XCTAssertTrue(messages.contains(.setEventData(["dropdown_selection_type": "document_type"])))
        XCTAssertTrue(messages.contains(.send))
    }
}
