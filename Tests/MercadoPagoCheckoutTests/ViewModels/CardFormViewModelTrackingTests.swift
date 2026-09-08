//
//  CardFormViewModelTrackingTests.swift
//  MercadoPagoSDK
//

import Combine
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
        repository: MockCardPaymentBrickCardRepository,
        analytics: MockAnalytics,
        errorObservability: MockErrorObservability
    )

    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle

    override func tearDown() {
        self.cancellables.removeAll()
        super.tearDown()
    }

    // MARK: - Stubs

    private enum IdentificationTypeStub {
        static let cpf = IdentificationType(id: "CPF", name: "CPF", type: "numeric", minLenght: 11, maxLenght: 11)
        static let cnpj = IdentificationType(id: "CNPJ", name: "CNPJ", type: "numeric", minLenght: 14, maxLenght: 14)
    }

    private enum CardTokenStub {
        static let valid = CardToken(
            token: "test_token_12345",
            publicKey: nil,
            bin: nil,
            expirationMonth: nil,
            expirationYear: nil,
            lastFourDigits: nil,
            cardHolder: nil,
            status: nil,
            dateCreated: nil,
            dateLastUpdated: nil,
            dateDue: nil,
            luhnValidation: nil,
            liveMode: nil,
            requireEsc: nil,
            cardNumberLength: nil,
            securityCodeLength: nil,
            truncCardNumber: nil
        )
    }

    private enum CardDataStub {
        static let visa = CardPaymentBrickCardData(
            securityCodeTranslations: nil,
            installment: nil,
            paymentMethods: [
                CardPaymentBrickCardData.PaymentMethod(
                    id: "visa",
                    paymentTypeId: "credit_card",
                    cardNumber: .init(type: "number", length: .init(min: 16, max: 16), mask: "XXXX XXXX XXXX XXXX"),
                    securityCode: nil,
                    issuers: []
                )
            ]
        )
    }

    private enum CardFormDataStub {
        static var valid: CardFormData {
            var form = CardFormData(fields: CardFormInitializationOutputStub.makeDefaultFields())
            form.cardNumber = "4111111111111111"
            form.cardHolder = "John Doe"
            form.expirationDate = "12/27"
            form.securityCode = "123"
            form.documentHolder = "12345678900"
            return form
        }
    }

    // MARK: - Helpers

    private func makeSUT(
        amount: Decimal = .zero,
        identificationTypes: [IdentificationType] = [],
        shouldSendMelidata: Bool = true
    ) -> SUT {
        let service = MockCheckoutService()
        let repository = MockCardPaymentBrickCardRepository()
        let analytics = MockAnalytics()
        let errorObservability = MockErrorObservability(
            eventID: "checkout-event",
            shouldSendMelidata: shouldSendMelidata
        )
        let config = CardFormViewModel.Configuration(
            amount: amount,
            checkoutTypeAnalyticsValue: "save_card",
            excludedPaymentTypeIds: [],
            excludedPaymentMethodIds: [],
            initResult: CardFormInitializationOutputStub.make(identificationTypes: identificationTypes),
            minInstallments: nil,
            maxInstallments: nil
        )
        let viewModel = CardFormViewModel(
            config: config,
            service: service,
            fetchCardUseCase: FetchCardPaymentBrickCardUseCase(repository: repository),
            analytics: analytics,
            errorObservability: errorObservability
        )
        return (viewModel, service, repository, analytics, errorObservability)
    }

    private func setupCardData(_ sut: SUT) async {
        await sut.repository.setResult(.success(CardDataStub.visa))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardData)
    }

    private func waitForChange<T>(
        _ publisher: Published<T>.Publisher,
        timeout: TimeInterval = 1.0
    ) async {
        let exp = expectation(description: "publisher value changed")
        publisher
            .dropFirst()
            .first()
            .sink { _ in exp.fulfill() }
            .store(in: &self.cancellables)
        await fulfillment(of: [exp], timeout: timeout)
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

    // MARK: - cancel

    func test_cancel_backButton_shouldTrackUserCanceledErrorEvent() async {
        // Arrange
        let sut = self.makeSUT()

        // Act
        sut.viewModel.cancel(context: MPCardFormUserCancelledContext(fields: []), reason: .backButton)
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        let eventIDs = await sut.analytics.mock.getObservabilityEventIDs()
        XCTAssertTrue(messages.contains(.track(path: CardFormAnalyticsPath.userCanceledError)))
        XCTAssertTrue(messages.contains(.send))
        XCTAssertEqual(eventIDs, ["checkout-event"])
        XCTAssertEqual(sut.errorObservability.recordedErrors().map(\.operation), [.cardFormCancellation])
    }

    func test_cancel_backButton_shouldSendBackButtonErrorType() async {
        // Arrange
        let sut = self.makeSUT()

        // Act
        sut.viewModel.cancel(context: MPCardFormUserCancelledContext(fields: []), reason: .backButton)
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.setEventData(["error_type": "user_tapped_back_button"])))
    }

    func test_cancel_dismissedScreen_shouldSendDismissedScreenErrorType() async {
        // Arrange
        let sut = self.makeSUT()

        // Act
        sut.viewModel.cancel(context: MPCardFormUserCancelledContext(fields: []), reason: .dismissedScreen)
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.setEventData(["error_type": "user_dismissed_screen"])))
    }

    // MARK: - trackDropdownSelection

    func test_trackDropdownSelection_shouldTrackDropdownSelectionEvent() async {
        // Arrange
        let sut = self.makeSUT()

        // Act
        sut.viewModel.trackDropdownSelection(selectedValue: "CNPJ")
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.track(path: CardFormAnalyticsPath.dropdownSelection)))
        XCTAssertTrue(messages.contains(.setEventData(["dropdown_selection_type": "CNPJ"])))
        XCTAssertTrue(messages.contains(.send))
    }

    func test_trackDropdownSelection_shouldSendSelectedValue() async {
        // Arrange
        let sut = self.makeSUT()

        // Act
        sut.viewModel.trackDropdownSelection(selectedValue: "CPF")
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.setEventData(["dropdown_selection_type": "CPF"])))
        XCTAssertFalse(messages.contains(.setEventData(["dropdown_selection_type": "CNPJ"])))
    }

    // MARK: - trackSubmitError

    func test_trackSubmitError_onTokenizationFailure_shouldTrackSubmitErrorEvent() async {
        // Arrange
        let sut = self.makeSUT()
        await self.setupCardData(sut)
        let tokenError = MercadoPagoCheckoutError(
            code: .networkConnectionFailed,
            localizedDescription: "No connection",
            location: .tokenization
        )
        await sut.service.setCreateCardTokenResult(.failure(tokenError))

        // Act
        await sut.viewModel.submitCardData(
            cardForm: CardFormDataStub.valid,
            onSuccess: { _ in },
            onFailure: { _ in }
        )
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        let eventIDs = await sut.analytics.mock.getObservabilityEventIDs()
        XCTAssertTrue(messages.contains(.track(path: CardFormAnalyticsPath.submitError)))
        XCTAssertTrue(messages.contains(.send))
        XCTAssertEqual(eventIDs, ["checkout-event"])
        XCTAssertEqual(sut.errorObservability.recordedErrors().map(\.operation), [.cardFormSubmission])
    }

    func test_submitFailure_whenMelidataDisabled_shouldKeepOriginalCallbackResult() async {
        let sut = self.makeSUT(shouldSendMelidata: false)
        await self.setupCardData(sut)
        let original = MercadoPagoCheckoutError(
            code: .networkConnectionFailed,
            localizedDescription: "No connection",
            location: .tokenization
        )
        await sut.service.setCreateCardTokenResult(.failure(original))
        var received: MercadoPagoCheckoutError?

        await sut.viewModel.submitCardData(
            cardForm: CardFormDataStub.valid,
            onSuccess: { _ in XCTFail("Expected failure") },
            onFailure: { received = $0 }
        )

        XCTAssertEqual(received?.code, original.code)
        XCTAssertEqual(received?.errorDescription, original.errorDescription)
        XCTAssertEqual(sut.errorObservability.recordedErrors().map(\.operation), [.cardFormSubmission])
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.isEmpty)
    }

    // MARK: - enqueueAnalytics

    func test_enqueueAnalytics_twoConsecutiveInputValidations_shouldNotInterleave() async {
        // Arrange
        let sut = self.makeSUT()

        // Act — fire two tracks without awaiting between them
        sut.viewModel.trackInputValidation(field: .cardNumber, isValid: true)
        sut.viewModel.trackInputValidation(field: .cardHolder, isValid: false)

        // Wait for both sends to complete
        await sut.analytics.mock.waitForSend(count: 2)

        // Assert — messages must arrive in two clean groups, not interleaved:
        // [track, setEventData, send] [track, setEventData, send]
        let messages = await sut.analytics.mock.getMessages()
        let sendIndices = messages.indices.filter { messages[$0] == .send }
        XCTAssertEqual(sendIndices.count, 2)

        let firstSendIdx = sendIndices[0]
        let secondSendIdx = sendIndices[1]

        // First group (before first send) must have exactly track + setEventData
        let firstGroup = Array(messages[0 ..< firstSendIdx])
        XCTAssertEqual(firstGroup.count, 2, "First event must have exactly [track, setEventData] before its send")
        XCTAssertTrue(firstGroup.contains(.track(path: CardFormAnalyticsPath.inputValidation)))
        XCTAssertTrue(firstGroup.contains(.setEventData(["field": "card_number", "is_input_valid": true])))

        // Second group (between first and second send) must have exactly track + setEventData
        let secondGroup = Array(messages[(firstSendIdx + 1) ..< secondSendIdx])
        XCTAssertEqual(secondGroup.count, 2, "Second event must have exactly [track, setEventData] before its send")
        XCTAssertTrue(secondGroup.contains(.track(path: CardFormAnalyticsPath.inputValidation)))
        XCTAssertTrue(secondGroup.contains(.setEventData(["field": "card_holder", "is_input_valid": false])))
    }

    func test_enqueueAnalytics_inputValidationAndDropdown_shouldNotInterleave() async {
        // Arrange
        let sut = self.makeSUT()

        // Act — fire input validation and dropdown selection consecutively
        sut.viewModel.trackInputValidation(field: .document, isValid: true)
        sut.viewModel.trackDropdownSelection(selectedValue: "CPF")

        await sut.analytics.mock.waitForSend(count: 2)

        // Assert — no interleaving between the two events
        let messages = await sut.analytics.mock.getMessages()
        let sendIndices = messages.indices.filter { messages[$0] == .send }
        XCTAssertEqual(sendIndices.count, 2)

        let firstSendIdx = sendIndices[0]
        let secondSendIdx = sendIndices[1]

        let firstGroup = Array(messages[0 ..< firstSendIdx])
        XCTAssertEqual(firstGroup.count, 2, "First event must have exactly [track, setEventData] before its send")

        let secondGroup = Array(messages[(firstSendIdx + 1) ..< secondSendIdx])
        XCTAssertEqual(secondGroup.count, 2, "Second event must have exactly [track, setEventData] before its send")
    }

    func test_enqueueAnalytics_cancelAndInputValidation_cancelShouldArriveFirst() async {
        // Arrange
        let sut = self.makeSUT()

        // Act — cancel blocks isCancelling so only cancel track fires
        sut.viewModel.cancel(context: MPCardFormUserCancelledContext(fields: []), reason: .backButton)
        sut.viewModel.trackInputValidation(field: .cardNumber, isValid: true)

        await sut.analytics.mock.waitForSend()

        // Assert — only the cancel event is tracked (input validation is guarded by isCancelling)
        let messages = await sut.analytics.mock.getMessages()
        let sendCount = messages.filter { $0 == .send }.count
        XCTAssertEqual(sendCount, 1, "Only cancel event should fire — input validation is blocked by isCancelling")
        XCTAssertTrue(messages.contains(.track(path: CardFormAnalyticsPath.userCanceledError)))
        XCTAssertFalse(messages.contains(.track(path: CardFormAnalyticsPath.inputValidation)))
    }

    func test_enqueueAnalytics_submitAndInputValidation_submitShouldArriveFirst() async {
        // Arrange
        let sut = self.makeSUT()
        await self.setupCardData(sut)
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))

        // Act — fire input validation then submit (submit track is enqueued via submitCardData)
        sut.viewModel.trackInputValidation(field: .cardHolder, isValid: true)

        await sut.viewModel.submitCardData(
            cardForm: CardFormDataStub.valid,
            onSuccess: { _ in },
            onFailure: { _ in }
        )

        await sut.analytics.mock.waitForSend(count: 2)

        // Assert — both events serialized; input validation appears before submit
        let messages = await sut.analytics.mock.getMessages()
        let sendIndices = messages.indices.filter { messages[$0] == .send }
        XCTAssertEqual(sendIndices.count, 2)

        // First event must be input validation
        let firstGroup = Array(messages[0 ..< sendIndices[0]])
        XCTAssertTrue(firstGroup.contains(.track(path: CardFormAnalyticsPath.inputValidation)))
        XCTAssertFalse(firstGroup.contains(.track(path: CardFormAnalyticsPath.submit)))

        // Second event must be submit
        let secondGroup = Array(messages[(sendIndices[0] + 1) ..< sendIndices[1]])
        XCTAssertTrue(secondGroup.contains(.track(path: CardFormAnalyticsPath.submit)))
        XCTAssertFalse(secondGroup.contains(.track(path: CardFormAnalyticsPath.inputValidation)))
    }
}
