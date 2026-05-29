//
//  CardFormViewModelTests.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 25/02/26.
//

import Combine
@testable import CoreMethods
@testable import MercadoPagoCheckout
@testable import MPComponents
@testable import MPFoundation
import XCTest

@MainActor
final class CardFormViewModelTests: XCTestCase {
    // MARK: - Types

    typealias SUT = (
        viewModel: CardFormViewModel,
        service: MockCheckoutService,
        repository: MockCardPaymentBrickCardRepository
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
        static let cpf = IdentificationType(
            id: "CPF",
            name: "CPF",
            type: "numeric",
            minLenght: 11,
            maxLenght: 11
        )
        static let cnpj = IdentificationType(
            id: "CNPJ",
            name: "CNPJ",
            type: "numeric",
            minLenght: 14,
            maxLenght: 14
        )
    }

    private enum CardDataStub {
        static let visa = makeCardData(id: "visa")
        static let master = makeCardData(id: "master")

        static let visaWithSecurityCode = makeCardData(
            id: "visa",
            securityCode: .init(mode: "mandatory", length: 3, type: "number", placeholder: "123", tooltip: "cvv_back_tooltip")
        )
        static let visaWithSecurityCodeTranslations = CardPaymentBrickCardData(
            securityCodeTranslations: CardFormFields.CVVField(
                label: "CVV",
                placeholder: "123",
                tooltip: "cvv_translations_tooltip",
                validation: .init(errorEmpty: "", errorIncomplete: "", errorInvalid: ""),
                config: .init(type: "number", length: .init(min: 3, max: 3))
            ),
            installment: nil,
            paymentMethods: [makePaymentMethod(id: "visa")]
        )
        static let amex = makeCardData(
            id: "amex",
            securityCode: .init(mode: "mandatory", length: 4, type: "number", placeholder: "1234", tooltip: "cvv_front_tooltip")
        )
        static let visaWithIssuer = CardPaymentBrickCardData(
            securityCodeTranslations: nil,
            installment: nil,
            paymentMethods: [
                CardPaymentBrickCardData.PaymentMethod(
                    id: "visa",
                    paymentTypeId: "credit_card",
                    cardNumber: .init(type: "number", length: .init(min: 16, max: 16), mask: "XXXX XXXX XXXX XXXX"),
                    securityCode: nil,
                    issuers: [.init(id: "24", name: "Bradesco")]
                )
            ]
        )

        static let emptyPaymentMethods = CardPaymentBrickCardData(
            securityCodeTranslations: nil,
            installment: nil,
            paymentMethods: []
        )

        private static func makeCardData(
            id: String,
            paymentTypeId: String = "credit_card",
            securityCode: CardPaymentBrickCardData.PaymentMethod.SecurityCodeInfo? = nil
        ) -> CardPaymentBrickCardData {
            CardPaymentBrickCardData(
                securityCodeTranslations: nil,
                installment: nil,
                paymentMethods: [self.makePaymentMethod(id: id, paymentTypeId: paymentTypeId, securityCode: securityCode)]
            )
        }

        private static func makePaymentMethod(
            id: String,
            paymentTypeId: String = "credit_card",
            securityCode: CardPaymentBrickCardData.PaymentMethod.SecurityCodeInfo? = nil
        ) -> CardPaymentBrickCardData.PaymentMethod {
            CardPaymentBrickCardData.PaymentMethod(
                id: id,
                paymentTypeId: paymentTypeId,
                cardNumber: .init(type: "number", length: .init(min: 16, max: 16), mask: "XXXX XXXX XXXX XXXX"),
                securityCode: securityCode,
                issuers: []
            )
        }
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

    private enum CardFormDataStub {
        static var validForm: CardFormData {
            var form = CardFormData(fields: CardFormInitializationOutputStub.makeDefaultFields())
            form.cardNumber = "4111111111111111"
            form.cardHolder = "John Doe"
            form.expirationDate = "12/27"
            form.securityCode = "123"
            form.documentHolder = "12345678900"
            return form
        }
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

    // MARK: - Helpers

    private func makeSUT(
        amount: Double = .zero,
        checkoutTypeAnalyticsValue: String = "save_card",
        identificationTypes: [IdentificationType] = []
    ) -> SUT {
        let service = MockCheckoutService()
        let repository = MockCardPaymentBrickCardRepository()
        let config = CardFormViewModel.Configuration(
            amount: amount,
            checkoutTypeAnalyticsValue: checkoutTypeAnalyticsValue,
            excludedPaymentTypeIds: [],
            excludedPaymentMethodIds: [],
            initResult: CardFormInitializationOutputStub.make(identificationTypes: identificationTypes)
        )
        let viewModel = CardFormViewModel(
            config: config,
            service: service,
            fetchCardUseCase: FetchCardPaymentBrickCardUseCase(repository: repository)
        )
        return (viewModel, service, repository)
    }

    private func makeSUTWithAmount(_ amount: Double) -> SUT {
        self.makeSUT(amount: amount, checkoutTypeAnalyticsValue: "card_transaction")
    }

    // MARK: - Init

    func test_init_cardDataShouldBeNil() {
        // Arrange / Act
        let sut = self.makeSUT()

        // Assert
        XCTAssertNil(sut.viewModel.cardData)
    }

    func test_init_binFetchErrorShouldBeNil() {
        // Arrange / Act
        let sut = self.makeSUT()

        // Assert
        XCTAssertNil(sut.viewModel.cardAcceptanceError)
    }

    func test_init_withIdentificationTypes_shouldSelectFirst() {
        // Arrange / Act
        let sut = self.makeSUT(identificationTypes: [IdentificationTypeStub.cpf, IdentificationTypeStub.cnpj])

        // Assert
        XCTAssertEqual(sut.viewModel.selectTypeDocument, IdentificationTypeStub.cpf)
    }

    func test_init_withNoIdentificationTypes_shouldSelectNil() {
        // Arrange / Act
        let sut = self.makeSUT()

        // Assert
        XCTAssertNil(sut.viewModel.selectTypeDocument)
    }

    // MARK: - onCardNumberChange

    func test_onCardNumberChange_whenDigitsLessThan8_shouldNotFetchCardData() {
        // Arrange
        let sut = self.makeSUT()

        // Act — synchronous: no task created for < 8 digits
        sut.viewModel.onCardNumberChange("1234567")

        // Assert
        XCTAssertNil(sut.viewModel.cardData)
        XCTAssertNil(sut.viewModel.cardAcceptanceError)
    }

    func test_onCardNumberChange_whenDigitsReach8_withSuccess_shouldSetCardData() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(CardDataStub.visa))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardData)

        // Assert
        XCTAssertEqual(sut.viewModel.cardData, CardDataStub.visa)
        XCTAssertNil(sut.viewModel.cardAcceptanceError)
    }

    func test_onCardNumberChange_whenDigitsReach8_withEmptyMethods_shouldSetAcceptanceError() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(CardDataStub.emptyPaymentMethods))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardAcceptanceError)

        // Assert
        XCTAssertNotNil(sut.viewModel.cardAcceptanceError)
        XCTAssertNil(sut.viewModel.cardData)
    }

    func test_onCardNumberChange_whenClearedBelow8Digits_shouldClearCardDataAndError() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(CardDataStub.visa))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardData)

        // Act — clearing to below 8 digits is synchronous
        sut.viewModel.onCardNumberChange("123")

        // Assert
        XCTAssertNil(sut.viewModel.cardData)
        XCTAssertNil(sut.viewModel.cardAcceptanceError)
    }

    func test_onCardNumberChange_whenSameBINCalledTwice_shouldNotRefetch() async {
        // Arrange — first call returns empty methods (triggers acceptance error)
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(CardDataStub.emptyPaymentMethods))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardAcceptanceError)
        XCTAssertNotNil(sut.viewModel.cardAcceptanceError)

        // Change result to success, but call with same BIN
        await sut.repository.setResult(.success(CardDataStub.visa))

        // Act — same BIN is rejected synchronously before any task is created
        sut.viewModel.onCardNumberChange("12345678")

        // Assert — state unchanged
        XCTAssertNotNil(sut.viewModel.cardAcceptanceError)
        XCTAssertNil(sut.viewModel.cardData)
    }

    func test_onCardNumberChange_whenDifferentBINAfterError_shouldRefetchAndClearError() async {
        // Arrange — first BIN returns empty methods
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(CardDataStub.emptyPaymentMethods))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardAcceptanceError)

        // Act — different BIN with success
        await sut.repository.setResult(.success(CardDataStub.master))
        sut.viewModel.onCardNumberChange("87654321")
        await self.waitForChange(sut.viewModel.$cardData)

        // Assert
        XCTAssertNil(sut.viewModel.cardAcceptanceError)
        XCTAssertEqual(sut.viewModel.cardData, CardDataStub.master)
    }

    func test_onCardNumberChange_whenFormattedCardNumber_shouldExtractBINCorrectly() async {
        // Arrange — formatted number "1234 5678 9012 3456"
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(CardDataStub.visa))

        // Act
        sut.viewModel.onCardNumberChange("1234 5678 9012 3456")
        await self.waitForChange(sut.viewModel.$cardData)

        // Assert — BIN extracted from digits only (12345678)
        XCTAssertEqual(sut.viewModel.cardData, CardDataStub.visa)
    }

    // MARK: - fetchBinData retry

    func test_onCardNumberChange_whenFirstFetchSucceeds_shouldCallRepositoryOnce() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(CardDataStub.visa))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardData)

        // Assert
        let callCount = await sut.repository.callCount
        XCTAssertEqual(sut.viewModel.cardData, CardDataStub.visa)
        XCTAssertEqual(callCount, 1)
    }

    func test_onCardNumberChange_whenFirstFetchFails_shouldRetryAndSetCardData() async {
        // Arrange
        let sut = self.makeSUT()
        let networkError = MercadoPagoCheckoutError(code: .networkConnectionFailed, localizedDescription: "timeout", location: .paymentMethods)
        await sut.repository.setSequentialResults(
            .failure(networkError),
            .success(CardDataStub.visa)
        )

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardData)

        // Assert
        let callCount = await sut.repository.callCount
        XCTAssertEqual(sut.viewModel.cardData, CardDataStub.visa)
        XCTAssertEqual(callCount, 2)
    }

    func test_onCardNumberChange_whenAllFetchesFail_shouldSetBinNetworkErrorAfter2Calls() async {
        // Arrange
        let sut = self.makeSUT()
        let networkError = MercadoPagoCheckoutError(code: .networkConnectionFailed, localizedDescription: "timeout", location: .paymentMethods)
        await sut.repository.setSequentialResults(
            .failure(networkError),
            .failure(networkError)
        )

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binNetworkError)

        // Assert
        let callCount = await sut.repository.callCount
        XCTAssertNotNil(sut.viewModel.binNetworkError)
        XCTAssertNil(sut.viewModel.cardData)
        XCTAssertEqual(callCount, 2)
    }

    func test_onCardNumberChange_whenEmptyPaymentMethods_shouldNotRetry() async {
        // Arrange — empty methods is a success response, not an error, so no retry
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(CardDataStub.emptyPaymentMethods))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardAcceptanceError)

        // Assert
        let callCount = await sut.repository.callCount
        XCTAssertNotNil(sut.viewModel.cardAcceptanceError)
        XCTAssertEqual(callCount, 1)
    }

    // MARK: - retryBinFetch

    func test_init_showSnackbarShouldBeFalse() {
        // Arrange / Act
        let sut = self.makeSUT()

        // Assert
        XCTAssertFalse(sut.viewModel.showSnackbar)
    }

    // MARK: - isSecurityCodeMandatory

    func test_isSecurityCodeMandatory_whenCardDataIsNil_shouldReturnTrue() {
        // Arrange / Act
        let sut = self.makeSUT()

        // Assert
        XCTAssertTrue(sut.viewModel.isSecurityCodeMandatory)
    }

    func test_isSecurityCodeMandatory_whenNoSecurityCode_shouldReturnFalse() async {
        // Arrange — visa stub has no securityCode in paymentMethods
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(CardDataStub.visa))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardData)

        // Assert
        XCTAssertFalse(sut.viewModel.isSecurityCodeMandatory)
    }

    func test_isSecurityCodeMandatory_whenSecurityCodePresent_shouldReturnTrue() async {
        // Arrange — visa stub has securityCode in paymentMethods
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(CardDataStub.visaWithSecurityCode))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardData)

        // Assert
        XCTAssertTrue(sut.viewModel.isSecurityCodeMandatory)
    }

    func test_isSecurityCodeMandatory_whenCardDataCleared_shouldReturnTrue() async {
        // Arrange — start with card data that has no securityCode in paymentMethods
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(CardDataStub.visa))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardData)
        XCTAssertFalse(sut.viewModel.isSecurityCodeMandatory)

        // Act — clearing below 8 digits resets cardData to nil synchronously
        sut.viewModel.onCardNumberChange("123")

        // Assert
        XCTAssertNil(sut.viewModel.cardData)
        XCTAssertTrue(sut.viewModel.isSecurityCodeMandatory)
    }

    // MARK: - cvvTooltipText

    func test_cvvTooltipText_whenCardDataIsNil_shouldReturnFieldDefault() {
        // Arrange / Act
        let sut = self.makeSUT()

        // Assert — returns fields.cvv.tooltip from initialization output
        XCTAssertEqual(sut.viewModel.cvvTooltipText, "")
    }

    func test_cvvTooltipText_whenNoSecurityCodeInfo_shouldReturnFieldDefault() async {
        // Arrange — visa stub has no securityCode
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(CardDataStub.visa))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardData)

        // Assert
        XCTAssertEqual(sut.viewModel.cvvTooltipText, "")
    }

    func test_cvvTooltipText_whenSecurityCodeHasTooltip_shouldReturnSecurityCodeTooltip() async {
        // Arrange — visa with security code tooltip
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(CardDataStub.visaWithSecurityCode))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardData)

        // Assert
        XCTAssertEqual(sut.viewModel.cvvTooltipText, "cvv_back_tooltip")
    }

    func test_cvvTooltipText_whenAmexSecurityCode_shouldReturnAmexTooltip() async {
        // Arrange — amex with front security code tooltip
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(CardDataStub.amex))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardData)

        // Assert
        XCTAssertEqual(sut.viewModel.cvvTooltipText, "cvv_front_tooltip")
    }

    func test_cvvTooltipText_whenCardDataCleared_shouldReturnFieldDefault() async {
        // Arrange — start with amex card
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(CardDataStub.amex))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardData)
        XCTAssertEqual(sut.viewModel.cvvTooltipText, "cvv_front_tooltip")

        // Act — clearing resets cardData to nil
        sut.viewModel.onCardNumberChange("123")

        // Assert
        XCTAssertEqual(sut.viewModel.cvvTooltipText, "")
    }

    func test_cvvTooltipText_whenSecurityCodeTranslationsPresent_shouldReturnTranslationsTooltip() async {
        // Arrange — no securityCode but securityCodeTranslations set
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(CardDataStub.visaWithSecurityCodeTranslations))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardData)

        // Assert — securityCodeTranslations.tooltip used as fallback
        XCTAssertEqual(sut.viewModel.cvvTooltipText, "cvv_translations_tooltip")
    }

    // MARK: - Acceptance errors (binValidation)

    func test_onCardNumberChange_whenEmptyPaymentMethodsWithMessage_shouldSetPaymentMethodNotFound() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.repository.setResult(.failure(APIClientError.apiError(APIErrorResponse(
            code: "400", message: "error",
            errorCode: "EMPTY_PAYMENT_METHODS",
            userErrorMessage: "Insira conforme está no cartão"
        ))))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardAcceptanceError)

        // Assert
        XCTAssertEqual(sut.viewModel.cardAcceptanceError, .paymentMethodNotFound("Insira conforme está no cartão"))
    }

    func test_onCardNumberChange_whenInstallmentsUnavailable_shouldSetPaymentMethodNotFound() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.repository.setResult(.failure(APIClientError.apiError(APIErrorResponse(
            code: "400", message: "error",
            errorCode: "INSTALLMENTS_UNAVAILABLE",
            userErrorMessage: "Insira conforme está no cartão"
        ))))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardAcceptanceError)

        // Assert
        XCTAssertEqual(sut.viewModel.cardAcceptanceError, .paymentMethodNotFound("Insira conforme está no cartão"))
    }

    func test_onCardNumberChange_whenIdentificationTypeUnavailable_shouldSetPaymentMethodNotFound() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.repository.setResult(.failure(APIClientError.apiError(APIErrorResponse(
            code: "400", message: "error",
            errorCode: "IDENTIFICATION_TYPE_UNAVAILABLE",
            userErrorMessage: "Insira conforme está no cartão"
        ))))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardAcceptanceError)

        // Assert
        XCTAssertEqual(sut.viewModel.cardAcceptanceError, .paymentMethodNotFound("Insira conforme está no cartão"))
    }

    func test_onCardNumberChange_whenUnsupportedSite_shouldSetBinNetworkError() async {
        // Arrange — UNSUPPORTED_SITE is not in binValidation → falls to binNetworkError (snackbar)
        let sut = self.makeSUT()
        await sut.repository.setResult(.failure(APIClientError.apiError(APIErrorResponse(
            code: "400", message: "error",
            errorCode: "UNSUPPORTED_SITE",
            userErrorMessage: "Your country is not supported"
        ))))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binNetworkError)

        // Assert
        XCTAssertNil(sut.viewModel.cardAcceptanceError)
        XCTAssertNotNil(sut.viewModel.binNetworkError)
    }

    // MARK: - retryBinFetch

    func test_retryBinFetch_whenNoPreviousError_shouldNotShowSnackbar() {
        // Arrange — no fetch has occurred
        let sut = self.makeSUT()

        // Act — guard: binFetchError == nil → retryBinFetch does nothing
        sut.viewModel.retryBinFetch()

        // Assert
        XCTAssertFalse(sut.viewModel.showSnackbar)
    }

    func test_retryBinFetch_whenCardDataIsPresent_shouldNotRetry() async {
        // Arrange — successful fetch means cardData != nil
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(CardDataStub.visa))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardData)
        XCTAssertNotNil(sut.viewModel.cardData)

        // Act — guard: cardData != nil → retryBinFetch does nothing
        sut.viewModel.retryBinFetch()

        // Assert
        XCTAssertFalse(sut.viewModel.showSnackbar)
    }

    func test_retryBinFetch_whenAcceptanceError_shouldNotRetry() async {
        // Arrange — acceptance error sets cardAcceptanceError (not a retriable error)
        let sut = self.makeSUT()
        await sut.repository.setResult(.failure(APIClientError.apiError(APIErrorResponse(code: "400", message: "error", errorCode: "EMPTY_PAYMENT_METHODS", userErrorMessage: nil))))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardAcceptanceError)
        XCTAssertEqual(sut.viewModel.cardAcceptanceError, .paymentMethodNotFound(""))

        // Act — guard: binNetworkError is nil → does nothing
        sut.viewModel.retryBinFetch()

        // Assert
        XCTAssertFalse(sut.viewModel.showSnackbar)
    }

    func test_retryBinFetch_whenNetworkError_andRetryFails_shouldShowSnackbar() async {
        // Arrange — initial fetch fails with networkError
        let sut = self.makeSUT()
        let networkError = MercadoPagoCheckoutError(code: .networkConnectionFailed, localizedDescription: "", location: .paymentMethods)
        await sut.repository.setResult(.failure(networkError))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binNetworkError)
        XCTAssertEqual(sut.viewModel.binNetworkError?.code, .networkConnectionFailed)

        // Act — retry also fails
        await sut.repository.setResult(.failure(networkError))
        sut.viewModel.retryBinFetch()
        await self.waitForChange(sut.viewModel.$showSnackbar)

        // Assert
        XCTAssertTrue(sut.viewModel.showSnackbar)
    }

    func test_retryBinFetch_whenServiceError_andRetryFails_shouldShowSnackbar() async {
        // Arrange — initial fetch fails with serviceError
        let sut = self.makeSUT()
        let serviceError = MercadoPagoCheckoutError(code: .serviceError, localizedDescription: "", location: .paymentMethods)
        await sut.repository.setResult(.failure(serviceError))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binNetworkError)
        XCTAssertEqual(sut.viewModel.binNetworkError?.code, .serviceError)

        // Act — retry also fails
        await sut.repository.setResult(.failure(serviceError))
        sut.viewModel.retryBinFetch()
        await self.waitForChange(sut.viewModel.$showSnackbar)

        // Assert
        XCTAssertTrue(sut.viewModel.showSnackbar)
    }

    func test_retryBinFetch_whenNetworkError_andRetrySucceeds_shouldNotShowSnackbar() async {
        // Arrange — initial fetch fails with networkError
        let sut = self.makeSUT()
        let networkError = MercadoPagoCheckoutError(code: .networkConnectionFailed, localizedDescription: "", location: .paymentMethods)
        await sut.repository.setResult(.failure(networkError))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binNetworkError)

        // Act — retry succeeds
        await sut.repository.setResult(.success(CardDataStub.visa))
        sut.viewModel.retryBinFetch()
        await self.waitForChange(sut.viewModel.$cardData)

        // Assert
        XCTAssertFalse(sut.viewModel.showSnackbar)
        XCTAssertNotNil(sut.viewModel.cardData)
    }

    // MARK: - footerAmount

    func test_footerAmount_whenConfigurationHasNoAmount_shouldReturnNil() {
        // Arrange / Act
        let sut = self.makeSUT()

        // Assert
        XCTAssertNil(sut.viewModel.footerAmount())
    }

    func test_footerAmount_whenConfigurationHasAmount_shouldReturnMPAmountData() {
        // Arrange / Act
        let sut = self.makeSUTWithAmount(500.0)

        // Assert
        XCTAssertEqual(sut.viewModel.footerAmount(), MPAmountData(from: 500.0))
    }

    // MARK: - submitCardData

    func test_submitCardData_saveCard_whenServiceSucceeds_shouldProduceOutputWithToken() async {
        // Arrange
        let sut = self.makeSUT()
        await self.setupCardData(sut)
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))
        var capturedOutput: CardFormOutput?

        // Act
        await sut.viewModel.submitCardData(
            cardForm: CardFormDataStub.validForm,
            onSuccess: { capturedOutput = $0 },
            onFailure: { XCTFail("Expected success, got error: \($0)") }
        )

        // Assert
        XCTAssertEqual(capturedOutput?.token, CardTokenStub.valid.token)
    }

    func test_submitCardData_cardTransaction_whenServiceSucceeds_shouldProduceOutputWithToken() async {
        // Arrange
        let sut = self.makeSUTWithAmount(100.0)
        await self.setupCardData(sut)
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))
        var capturedOutput: CardFormOutput?

        // Act
        await sut.viewModel.submitCardData(
            cardForm: CardFormDataStub.validForm,
            onSuccess: { capturedOutput = $0 },
            onFailure: { XCTFail("Expected success, got error: \($0)") }
        )

        // Assert
        XCTAssertEqual(capturedOutput?.token, CardTokenStub.valid.token)
    }

    func test_submitCardData_whenServiceFails_shouldCallOnFailure() async {
        // Arrange
        let sut = self.makeSUT()
        await self.setupCardData(sut)
        await sut.service.setCreateCardTokenResult(.failure(MockCheckoutService.MockError.resultNotSet))
        var capturedError: MercadoPagoCheckoutError?

        // Act
        await sut.viewModel.submitCardData(
            cardForm: CardFormDataStub.validForm,
            onSuccess: { _ in XCTFail("Expected failure") },
            onFailure: { capturedError = $0 }
        )

        // Assert
        XCTAssertNotNil(capturedError)
    }

    func test_submitCardData_whenCardDataIsNil_shouldCallOnFailure() async {
        // Arrange — no fetch triggered, cardData remains nil
        let sut = self.makeSUT()
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))
        var capturedError: MercadoPagoCheckoutError?

        // Act
        await sut.viewModel.submitCardData(
            cardForm: CardFormDataStub.validForm,
            onSuccess: { _ in XCTFail("Expected failure due to missing card data") },
            onFailure: { capturedError = $0 }
        )

        // Assert — buildCardSave/buildCardTransaction both require cardData
        XCTAssertEqual(capturedError?.code, .unknown)
        XCTAssertEqual(capturedError?.locationDescription, "paymentMethods")
    }

    func test_submitCardData_shouldResetIsTokenizingAfterCompletion() async {
        // Arrange
        let sut = self.makeSUT()
        await self.setupCardData(sut)
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))

        // Act
        await sut.viewModel.submitCardData(
            cardForm: CardFormDataStub.validForm,
            onSuccess: { _ in },
            onFailure: { _ in }
        )

        // Assert
        XCTAssertFalse(sut.viewModel.isTokenizing)
    }

    func test_submitCardData_shouldStripSpacesFromCardNumber() async {
        // Arrange
        let sut = self.makeSUT()
        await self.setupCardData(sut)
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))
        var cardForm = CardFormDataStub.validForm
        cardForm.cardNumber = "4111 1111 1111 1111"

        // Act
        await sut.viewModel.submitCardData(
            cardForm: cardForm,
            onSuccess: { _ in },
            onFailure: { XCTFail("Expected success, got error: \($0)") }
        )

        // Assert
        let captured = await sut.service.capturedCardParams
        XCTAssertEqual(captured?.cardNumber, "4111111111111111")
    }

    func test_submitCardData_shouldPrefixYearWithCurrentCentury() async {
        // Arrange
        let sut = self.makeSUT()
        await self.setupCardData(sut)
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))
        var cardForm = CardFormDataStub.validForm
        cardForm.expirationDate = "12/27"

        // Act
        await sut.viewModel.submitCardData(
            cardForm: cardForm,
            onSuccess: { _ in },
            onFailure: { XCTFail("Expected success, got error: \($0)") }
        )

        // Assert
        let captured = await sut.service.capturedCardParams
        let expectedCentury = Calendar.current.component(.year, from: Date()) / 100
        XCTAssertEqual(captured?.expirationYear, "\(expectedCentury)27")
        XCTAssertEqual(captured?.expirationMonth, "12")
    }

    func test_submitCardData_shouldStripMaskFromDocument() async {
        // Arrange
        let sut = self.makeSUT()
        await self.setupCardData(sut)
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))
        var cardForm = CardFormDataStub.validForm
        cardForm.documentHolder = "123.456.789-09"

        // Act
        await sut.viewModel.submitCardData(
            cardForm: cardForm,
            onSuccess: { _ in },
            onFailure: { XCTFail("Expected success, got error: \($0)") }
        )

        // Assert
        let captured = await sut.service.capturedCardParams
        XCTAssertEqual(captured?.documentNumber, "12345678909")
    }

    func test_submitCardData_whenCalledWithDocumentTypeSelected_shouldPassDocumentType() async {
        // Arrange
        let sut = self.makeSUT(identificationTypes: [IdentificationTypeStub.cpf])
        await self.setupCardData(sut)
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))

        // Act
        await sut.viewModel.submitCardData(
            cardForm: CardFormDataStub.validForm,
            onSuccess: { _ in },
            onFailure: { XCTFail("Expected success, got error: \($0)") }
        )

        // Assert
        let captured = await sut.service.capturedCardParams
        XCTAssertEqual(captured?.documentType, IdentificationTypeStub.cpf.id)
    }

    func test_submitCardData_whenDocumentTypeIsSelected_shouldIncludePayerInOutput() async {
        // Arrange
        let sut = self.makeSUT(identificationTypes: [IdentificationTypeStub.cpf])
        await self.setupCardData(sut)
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))
        var cardForm = CardFormDataStub.validForm
        cardForm.documentHolder = "12345678900"
        var capturedOutput: CardFormOutput?

        // Act
        await sut.viewModel.submitCardData(
            cardForm: cardForm,
            onSuccess: { capturedOutput = $0 },
            onFailure: { XCTFail("Expected success, got error: \($0)") }
        )

        // Assert
        XCTAssertEqual(capturedOutput?.payer?.documentType, IdentificationTypeStub.cpf.id)
        XCTAssertEqual(capturedOutput?.payer?.documentNumber, "12345678900")
    }

    func test_submitCardData_whenCardDataIsAvailable_shouldIncludePaymentMethodAndTypeIds() async {
        // Arrange
        let sut = self.makeSUT(identificationTypes: [IdentificationTypeStub.cpf])
        await sut.repository.setResult(.success(CardDataStub.visa))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardData)
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))
        var capturedOutput: CardFormOutput?

        // Act
        await sut.viewModel.submitCardData(
            cardForm: CardFormDataStub.validForm,
            onSuccess: { capturedOutput = $0 },
            onFailure: { XCTFail("Expected success, got error: \($0)") }
        )

        // Assert
        XCTAssertEqual(capturedOutput?.paymentMethodId, "visa")
        XCTAssertEqual(capturedOutput?.paymentTypeId, "credit_card")
    }

    func test_submitCardData_whenCardDataHasIssuer_shouldIncludeIssuerId() async {
        // Arrange
        let sut = self.makeSUT(identificationTypes: [IdentificationTypeStub.cpf])
        await sut.repository.setResult(.success(CardDataStub.visaWithIssuer))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardData)
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))
        var capturedOutput: CardFormOutput?

        // Act
        await sut.viewModel.submitCardData(
            cardForm: CardFormDataStub.validForm,
            onSuccess: { capturedOutput = $0 },
            onFailure: { XCTFail("Expected success, got error: \($0)") }
        )

        // Assert
        XCTAssertEqual(capturedOutput?.issuerId, "24")
    }

    func test_retryBinFetch_whenCalledTwice_withNetworkError_shouldShowSnackbarBothTimes() async {
        // Arrange — initial fetch fails
        let sut = self.makeSUT()
        let networkError = MercadoPagoCheckoutError(code: .networkConnectionFailed, localizedDescription: "", location: .paymentMethods)
        await sut.repository.setResult(.failure(networkError))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binNetworkError)

        // First retry fails → showSnackbar becomes true
        await sut.repository.setResult(.failure(networkError))
        sut.viewModel.retryBinFetch()
        await self.waitForChange(sut.viewModel.$showSnackbar)
        XCTAssertTrue(sut.viewModel.showSnackbar)

        // Second retry: observe showSnackbar going false (reset) then true (failure)
        let exp = expectation(description: "showSnackbar toggles false→true on second retry")
        var capturedValues: [Bool] = []
        sut.viewModel.$showSnackbar
            .dropFirst() // skip current true
            .prefix(2) // capture: false (reset), true (failure)
            .collect()
            .sink { values in
                capturedValues = values
                exp.fulfill()
            }
            .store(in: &self.cancellables)

        await sut.repository.setResult(.failure(networkError))
        sut.viewModel.retryBinFetch()
        await fulfillment(of: [exp], timeout: 1.0)

        // Assert — snackbar was reset then re-triggered
        XCTAssertEqual(capturedValues, [false, true])
    }

    // MARK: - keyboard type (derived from selectTypeDocument)

    func test_init_withNumericIdentificationType_shouldSelectNumericType() {
        // Arrange
        let numericType = IdentificationType(id: "CPF", name: "CPF", type: "number", minLenght: 11, maxLenght: 11)

        // Act
        let sut = self.makeSUT(identificationTypes: [numericType])

        // Assert — keyboard type is derived by the View via getKeyboardType()
        XCTAssertEqual(sut.viewModel.selectTypeDocument?.getKeyboardType(), .numberPad)
    }

    func test_init_withStringIdentificationType_shouldSelectStringType() {
        // Arrange
        let stringType = IdentificationType(id: "CNPJ", name: "CNPJ", type: "string", minLenght: 14, maxLenght: 14)

        // Act
        let sut = self.makeSUT(identificationTypes: [stringType])

        // Assert
        XCTAssertEqual(sut.viewModel.selectTypeDocument?.getKeyboardType(), .default)
    }
}
