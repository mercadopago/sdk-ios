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
        service: MockCheckoutService
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

    private enum CardBinDataStub {
        static let visa = CardBinData(
            paymentMethod: makePaymentMethod(id: "visa", paymentTypeId: "credit_card"),
            issuer: nil,
            installment: nil
        )
        static let master = CardBinData(
            paymentMethod: makePaymentMethod(id: "master", paymentTypeId: "credit_card"),
            issuer: nil,
            installment: nil
        )

        static let visaWithCVV = CardBinData(
            paymentMethod: makePaymentMethodWithCard(id: "visa", paymentTypeId: "credit_card", securityCodeLength: 3),
            issuer: nil,
            installment: nil
        )
        static let visaOptionalCVV = CardBinData(
            paymentMethod: makePaymentMethodWithCard(id: "visa", paymentTypeId: "credit_card", securityCodeLength: 0),
            issuer: nil,
            installment: nil
        )
        static let amex = CardBinData(
            paymentMethod: makePaymentMethodWithCard(id: "amex", paymentTypeId: "credit_card", securityCodeLength: 4, location: "front"),
            issuer: nil,
            installment: nil
        )

        private static func makePaymentMethod(id: String, paymentTypeId: String) -> PaymentMethod {
            PaymentMethod(
                id: id,
                paymentTypeId: paymentTypeId,
                status: "active",
                processingMode: "aggregator",
                accreditationTime: 0,
                merchantAccountId: "",
                siteId: "MLB",
                thumbnail: nil,
                minAccreditationDays: 0,
                maxAccreditationDays: 0,
                totalFinancialCost: 0,
                financialInstitution: nil,
                issuer: nil,
                card: nil,
                bins: nil,
                marketplace: nil,
                deferredCapture: nil,
                agreements: nil,
                payerCosts: nil,
                labels: nil,
                additionalInfoNeeded: nil
            )
        }

        private static func makePaymentMethodWithCard(
            id: String,
            paymentTypeId: String,
            securityCodeLength: Int,
            location: String = "back"
        ) -> PaymentMethod {
            PaymentMethod(
                id: id,
                paymentTypeId: paymentTypeId,
                status: "active",
                processingMode: "aggregator",
                accreditationTime: 0,
                merchantAccountId: "",
                siteId: "MLB",
                thumbnail: nil,
                minAccreditationDays: 0,
                maxAccreditationDays: 0,
                totalFinancialCost: 0,
                financialInstitution: nil,
                issuer: nil,
                card: PaymentMethod.CardInfo(
                    bin: 0,
                    length: .init(min: 16, max: 16),
                    validation: "standard",
                    securityCode: .init(mode: "mandatory", location: location, length: securityCodeLength)
                ),
                bins: nil,
                marketplace: nil,
                deferredCapture: nil,
                agreements: nil,
                payerCosts: nil,
                labels: nil,
                additionalInfoNeeded: nil
            )
        }
    }

    // MARK: - Helpers

    private func makeSUT() -> SUT {
        let service = MockCheckoutService()
        let configuration = MercadoPagoCheckout.CheckoutConfiguration(
            type: .cardForm(cardFormConfiguration: .init()),
            paymentMethod: [.card(allowedTypes: [.credit, .debit, .prepaid])]
        )
        let viewModel = CardFormViewModel(configuration: configuration, service: service)
        return (viewModel, service)
    }

    private func makeSUTWithAmount(_ amount: Double) -> SUT {
        let service = MockCheckoutService()
        let configuration = MercadoPagoCheckout.CheckoutConfiguration(
            type: .cardForm(cardFormConfiguration: .init(amount: amount)),
            paymentMethod: [.card(allowedTypes: [.credit, .debit, .prepaid])]
        )
        let viewModel = CardFormViewModel(configuration: configuration, service: service)
        return (viewModel, service)
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

    private enum IssuerStub {
        static let bradesco = Issuer(
            id: "24",
            name: "Bradesco",
            merchantAccountId: "",
            processingMode: "aggregator",
            status: "active",
            thumbnail: ""
        )
    }

    private enum CardFormDataStub {
        static var validForm: CardFormData {
            var form = CardFormData()
            form.cardNumber = "4111111111111111"
            form.cardHolder = "John Doe"
            form.expirationDate = "12/27"
            form.securityCode = "123"
            form.documentHolder = "12345678900"
            return form
        }
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

    // MARK: - Init

    func test_init_screenStateShouldBeLoading() {
        // Arrange / Act
        let sut = self.makeSUT()

        // Assert
        XCTAssertEqual(sut.viewModel.screenState, .loading)
    }

    func test_init_binDataShouldBeNil() {
        // Arrange / Act
        let sut = self.makeSUT()

        // Assert
        XCTAssertNil(sut.viewModel.binData)
    }

    func test_init_binFetchErrorShouldBeNil() {
        // Arrange / Act
        let sut = self.makeSUT()

        // Assert
        XCTAssertNil(sut.viewModel.cardAcceptanceError)
    }

    // MARK: - loadIdentificationTypes

    func test_loadIdentificationTypes_whenSuccess_shouldSetReadyState() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setIdentificationTypesResult(.success([IdentificationTypeStub.cpf]))

        // Act
        await sut.viewModel.loadIdentificationTypes()

        // Assert
        XCTAssertEqual(sut.viewModel.screenState, .ready)
    }

    func test_loadIdentificationTypes_whenSuccess_withTypes_shouldUpdateSelectTypeDocument() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setIdentificationTypesResult(.success([IdentificationTypeStub.cpf, IdentificationTypeStub.cnpj]))

        // Act
        await sut.viewModel.loadIdentificationTypes()

        // Assert
        XCTAssertEqual(sut.viewModel.selectTypeDocument, IdentificationTypeStub.cpf)
    }

    func test_loadIdentificationTypes_whenSuccess_withEmptyTypes_shouldKeepDefaultDocument() async {
        // Arrange
        let sut = self.makeSUT()
        let defaultDocument = sut.viewModel.selectTypeDocument
        await sut.service.setIdentificationTypesResult(.success([]))

        // Act
        await sut.viewModel.loadIdentificationTypes()

        // Assert
        XCTAssertEqual(sut.viewModel.selectTypeDocument, defaultDocument)
        XCTAssertEqual(sut.viewModel.screenState, .ready)
    }

    func test_loadIdentificationTypes_whenError_shouldSetReadyState() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setIdentificationTypesResult(.failure(MockCheckoutService.MockError.resultNotSet))

        // Act
        await sut.viewModel.loadIdentificationTypes()

        // Assert
        XCTAssertEqual(sut.viewModel.screenState, .ready)
    }

    func test_loadIdentificationTypes_whenError_shouldKeepDefaultDocument() async {
        // Arrange
        let sut = self.makeSUT()
        let defaultDocument = sut.viewModel.selectTypeDocument
        await sut.service.setIdentificationTypesResult(.failure(MockCheckoutService.MockError.resultNotSet))

        // Act
        await sut.viewModel.loadIdentificationTypes()

        // Assert
        XCTAssertEqual(sut.viewModel.selectTypeDocument, defaultDocument)
    }

    func test_loadIdentificationTypes_whenFirstAttemptFails_andRetrySucceeds_shouldSetTypes() async {
        // Arrange — first call fails, second (retry) succeeds
        let sut = self.makeSUT()
        await sut.service.setSequentialIdentificationTypesResults(
            .failure(MockCheckoutService.MockError.resultNotSet),
            .success([IdentificationTypeStub.cpf])
        )

        // Act
        await sut.viewModel.loadIdentificationTypes()

        // Assert
        XCTAssertEqual(sut.viewModel.screenState, .ready)
        XCTAssertEqual(sut.viewModel.selectTypeDocument, IdentificationTypeStub.cpf)
    }

    func test_loadIdentificationTypes_whenBothAttemptsFail_shouldSetReadyStateWithoutTypes() async {
        // Arrange — both attempts fail
        let sut = self.makeSUT()
        await sut.service.setSequentialIdentificationTypesResults(
            .failure(MockCheckoutService.MockError.resultNotSet),
            .failure(MockCheckoutService.MockError.resultNotSet)
        )

        // Act
        await sut.viewModel.loadIdentificationTypes()

        // Assert
        XCTAssertEqual(sut.viewModel.screenState, .ready)
        XCTAssertTrue(sut.viewModel.identificationTypes.isEmpty)
    }

    // MARK: - onCardNumberChange

    func test_onCardNumberChange_whenDigitsLessThan8_shouldNotFetchBinData() {
        // Arrange
        let sut = self.makeSUT()

        // Act — synchronous: no task created for < 8 digits
        sut.viewModel.onCardNumberChange("1234567")

        // Assert
        XCTAssertNil(sut.viewModel.binData)
        XCTAssertNil(sut.viewModel.cardAcceptanceError)
    }

    func test_onCardNumberChange_whenDigitsReach8_withSuccess_shouldSetBinData() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.visa))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binData)

        // Assert
        XCTAssertEqual(sut.viewModel.binData, CardBinDataStub.visa)
        XCTAssertNil(sut.viewModel.cardAcceptanceError)
    }

    func test_onCardNumberChange_whenDigitsReach8_withError_shouldSetApiError() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.failure(CardAcceptanceError.paymentMethodNotAllowed("visa")))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardAcceptanceError)

        // Assert
        XCTAssertNotNil(sut.viewModel.cardAcceptanceError)
        XCTAssertNil(sut.viewModel.binData)
    }

    func test_onCardNumberChange_whenClearedBelow8Digits_shouldClearBinDataAndError() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.visa))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binData)

        // Act — clearing to below 8 digits is synchronous
        sut.viewModel.onCardNumberChange("123")

        // Assert
        XCTAssertNil(sut.viewModel.binData)
        XCTAssertNil(sut.viewModel.cardAcceptanceError)
    }

    func test_onCardNumberChange_whenSameBINCalledTwice_shouldNotRefetch() async {
        // Arrange — first call fails
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.failure(CardAcceptanceError.paymentMethodNotAllowed("visa")))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardAcceptanceError)
        XCTAssertNotNil(sut.viewModel.cardAcceptanceError)

        // Change result to success, but call with same BIN
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.visa))

        // Act — same BIN is rejected synchronously before any task is created
        sut.viewModel.onCardNumberChange("12345678")

        // Assert — state unchanged
        XCTAssertNotNil(sut.viewModel.cardAcceptanceError)
        XCTAssertNil(sut.viewModel.binData)
    }

    func test_onCardNumberChange_whenDifferentBINAfterError_shouldRefetchAndClearError() async {
        // Arrange — first BIN fails
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.failure(CardAcceptanceError.paymentMethodNotAllowed("visa")))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardAcceptanceError)

        // Act — different BIN with success
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.master))
        sut.viewModel.onCardNumberChange("87654321")
        await self.waitForChange(sut.viewModel.$binData)

        // Assert
        XCTAssertNil(sut.viewModel.cardAcceptanceError)
        XCTAssertEqual(sut.viewModel.binData, CardBinDataStub.master)
    }

    func test_onCardNumberChange_whenFormattedCardNumber_shouldExtractBINCorrectly() async {
        // Arrange — formatted number "1234 5678 9012 3456"
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.visa))

        // Act
        sut.viewModel.onCardNumberChange("1234 5678 9012 3456")
        await self.waitForChange(sut.viewModel.$binData)

        // Assert — BIN extracted from digits only (12345678)
        XCTAssertEqual(sut.viewModel.binData, CardBinDataStub.visa)
    }

    // MARK: - retryBinFetch

    func test_init_showSnackbarShouldBeFalse() {
        // Arrange / Act
        let sut = self.makeSUT()

        // Assert
        XCTAssertFalse(sut.viewModel.showSnackbar)
    }

    // MARK: - isSecurityCodeMandatory

    func test_isSecurityCodeMandatory_whenBinDataIsNil_shouldReturnTrue() {
        // Arrange / Act
        let sut = self.makeSUT()

        // Assert
        XCTAssertTrue(sut.viewModel.isSecurityCodeMandatory)
    }

    func test_isSecurityCodeMandatory_whenCardInfoIsNil_shouldReturnTrue() async {
        // Arrange — visa stub has card: nil
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.visa))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binData)

        // Assert
        XCTAssertTrue(sut.viewModel.isSecurityCodeMandatory)
    }

    func test_isSecurityCodeMandatory_whenSecurityCodeLengthIsPositive_shouldReturnTrue() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.visaWithCVV))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binData)

        // Assert
        XCTAssertTrue(sut.viewModel.isSecurityCodeMandatory)
    }

    func test_isSecurityCodeMandatory_whenSecurityCodeLengthIsZero_shouldReturnFalse() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.visaOptionalCVV))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binData)

        // Assert
        XCTAssertFalse(sut.viewModel.isSecurityCodeMandatory)
    }

    func test_isSecurityCodeMandatory_whenBinDataCleared_shouldReturnTrue() async {
        // Arrange — start with optional CVV
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.visaOptionalCVV))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binData)
        XCTAssertFalse(sut.viewModel.isSecurityCodeMandatory)

        // Act — clearing below 8 digits resets binData to nil synchronously
        sut.viewModel.onCardNumberChange("123")

        // Assert
        XCTAssertNil(sut.viewModel.binData)
        XCTAssertTrue(sut.viewModel.isSecurityCodeMandatory)
    }

    // MARK: - cvvTooltipText

    func test_cvvTooltipText_whenBinDataIsNil_shouldReturnStaticDefault() {
        // Arrange / Act
        let sut = self.makeSUT()

        // Assert
        XCTAssertEqual(sut.viewModel.cvvTooltipText, MPStrings.CardForm.CVV.tooltipStatic(length: 3, location: "back"))
    }

    func test_cvvTooltipText_whenCardInfoIsNil_shouldReturnStaticDefault() async {
        // Arrange — visa stub has card: nil
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.visa))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binData)

        // Assert
        XCTAssertEqual(sut.viewModel.cvvTooltipText, MPStrings.CardForm.CVV.tooltipStatic(length: 3, location: "back"))
    }

    func test_cvvTooltipText_whenLocationIsBack_shouldReturnStaticDefault() async throws {
        // Arrange — visa with 3-digit CVV, location: "back"
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.visaWithCVV))
        let securityCode = try XCTUnwrap(CardBinDataStub.visaWithCVV.paymentMethod.card?.securityCode)
        let expectedText = MPStrings.CardForm.CVV.tooltipStatic(length: securityCode.length, location: securityCode.location)

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binData)

        // Assert
        XCTAssertEqual(sut.viewModel.cvvTooltipText, expectedText)
    }

    func test_cvvTooltipText_whenLocationIsFrontAndAmexLength_shouldReturnStaticAmex() async throws {
        // Arrange — amex with 4-digit CVV, location: "front"
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.amex))
        let securityCode = try XCTUnwrap(CardBinDataStub.amex.paymentMethod.card?.securityCode)
        let expectedText = MPStrings.CardForm.CVV.tooltipStatic(length: securityCode.length, location: securityCode.location)

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binData)

        // Assert
        XCTAssertEqual(sut.viewModel.cvvTooltipText, expectedText)
    }

    func test_cvvTooltipText_whenBinDataCleared_shouldReturnStaticDefault() async throws {
        // Arrange — start with amex card
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.amex))
        let amexSecurityCode = try XCTUnwrap(CardBinDataStub.amex.paymentMethod.card?.securityCode)
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binData)
        XCTAssertEqual(sut.viewModel.cvvTooltipText, MPStrings.CardForm.CVV.tooltipStatic(length: amexSecurityCode.length, location: amexSecurityCode.location))

        // Act — clearing resets binData to nil
        sut.viewModel.onCardNumberChange("123")

        // Assert
        XCTAssertEqual(sut.viewModel.cvvTooltipText, MPStrings.CardForm.CVV.tooltipStatic(length: 3, location: "back"))
    }

    // MARK: - retryBinFetch

    func test_retryBinFetch_whenNoPreviousError_shouldNotShowSnackbar() {
        // Arrange — no BIN fetch has occurred
        let sut = self.makeSUT()

        // Act — guard: binFetchError == nil → retryBinFetch does nothing
        sut.viewModel.retryBinFetch()

        // Assert
        XCTAssertFalse(sut.viewModel.showSnackbar)
    }

    func test_retryBinFetch_whenBinDataIsPresent_shouldNotRetry() async {
        // Arrange — successful fetch means binData != nil
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.visa))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binData)
        XCTAssertNotNil(sut.viewModel.binData)

        // Act — guard: binData != nil → retryBinFetch does nothing
        sut.viewModel.retryBinFetch()

        // Assert
        XCTAssertFalse(sut.viewModel.showSnackbar)
    }

    func test_retryBinFetch_whenValidationError_shouldNotRetry() async {
        // Arrange — paymentMethodNotAllowed is not a retriable error
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.failure(CardAcceptanceError.paymentMethodNotAllowed("visa")))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$cardAcceptanceError)
        XCTAssertEqual(sut.viewModel.cardAcceptanceError, .paymentMethodNotAllowed("visa"))

        // Act — guard: binFetchError is not .networkError/.serviceError → does nothing
        sut.viewModel.retryBinFetch()

        // Assert
        XCTAssertFalse(sut.viewModel.showSnackbar)
    }

    func test_retryBinFetch_whenNetworkError_andRetryFails_shouldShowSnackbar() async {
        // Arrange — initial fetch fails with networkError
        let sut = self.makeSUT()
        let networkError = MercadoPagoCheckoutError(code: .networkConnectionFailed, _localizedDescription: "", location: .paymentMethods)
        await sut.service.setFetchBinDataResult(.failure(networkError))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binNetworkError)
        XCTAssertEqual(sut.viewModel.binNetworkError?.code, .networkConnectionFailed)

        // Act — retry also fails
        await sut.service.setFetchBinDataResult(.failure(networkError))
        sut.viewModel.retryBinFetch()
        await self.waitForChange(sut.viewModel.$showSnackbar)

        // Assert
        XCTAssertTrue(sut.viewModel.showSnackbar)
    }

    func test_retryBinFetch_whenServiceError_andRetryFails_shouldShowSnackbar() async {
        // Arrange — initial fetch fails with serviceError
        let sut = self.makeSUT()
        let serviceError = MercadoPagoCheckoutError(code: .serviceError, _localizedDescription: "", location: .paymentMethods)
        await sut.service.setFetchBinDataResult(.failure(serviceError))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binNetworkError)
        XCTAssertEqual(sut.viewModel.binNetworkError?.code, .serviceError)

        // Act — retry also fails
        await sut.service.setFetchBinDataResult(.failure(serviceError))
        sut.viewModel.retryBinFetch()
        await self.waitForChange(sut.viewModel.$showSnackbar)

        // Assert
        XCTAssertTrue(sut.viewModel.showSnackbar)
    }

    func test_retryBinFetch_whenNetworkError_andRetrySucceeds_shouldNotShowSnackbar() async {
        // Arrange — initial fetch fails with networkError
        let sut = self.makeSUT()
        let networkError = MercadoPagoCheckoutError(code: .networkConnectionFailed, _localizedDescription: "", location: .paymentMethods)
        await sut.service.setFetchBinDataResult(.failure(networkError))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binNetworkError)

        // Act — retry succeeds
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.visa))
        sut.viewModel.retryBinFetch()
        await self.waitForChange(sut.viewModel.$binData)

        // Assert
        XCTAssertFalse(sut.viewModel.showSnackbar)
        XCTAssertNotNil(sut.viewModel.binData)
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

    // MARK: - submitPaymentData

    func test_submitPaymentData_whenServiceSucceeds_shouldReturnPaymentDataWithToken() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))

        // Act
        let result = try await sut.viewModel.submitPaymentData(nil, cardFormData: CardFormDataStub.validForm)

        // Assert
        XCTAssertEqual(result.token, CardTokenStub.valid.token)
    }

    func test_submitPaymentData_whenServiceFails_shouldThrowError() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setCreateCardTokenResult(.failure(MockCheckoutService.MockError.resultNotSet))

        // Act & Assert
        do {
            _ = try await sut.viewModel.submitPaymentData(nil, cardFormData: CardFormDataStub.validForm)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is MockCheckoutService.MockError)
        }
    }

    func test_submitPaymentData_shouldSetIsTokenizingTrue() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))

        // Act
        _ = try await sut.viewModel.submitPaymentData(nil, cardFormData: CardFormDataStub.validForm)

        // Assert
        XCTAssertTrue(sut.viewModel.isTokenizing)
    }

    func test_submitPaymentData_shouldStripSpacesFromCardNumber() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))
        var cardForm = CardFormDataStub.validForm
        cardForm.cardNumber = "4111 1111 1111 1111"

        // Act
        _ = try await sut.viewModel.submitPaymentData(nil, cardFormData: cardForm)

        // Assert
        let captured = await sut.service.capturedCardParams
        XCTAssertEqual(captured?.cardNumber, "4111111111111111")
    }

    func test_submitPaymentData_shouldPrefixYearWithCurrentCentury() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))
        var cardForm = CardFormDataStub.validForm
        cardForm.expirationDate = "12/27"

        // Act
        _ = try await sut.viewModel.submitPaymentData(nil, cardFormData: cardForm)

        // Assert
        let captured = await sut.service.capturedCardParams
        let expectedCentury = Calendar.current.component(.year, from: Date()) / 100
        XCTAssertEqual(captured?.expirationYear, "\(expectedCentury)27")
        XCTAssertEqual(captured?.expirationMonth, "12")
    }

    func test_submitPaymentData_shouldStripMaskFromDocument() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))
        var cardForm = CardFormDataStub.validForm
        cardForm.documentHolder = "123.456.789-09"

        // Act
        _ = try await sut.viewModel.submitPaymentData(nil, cardFormData: cardForm)

        // Assert
        let captured = await sut.service.capturedCardParams
        XCTAssertEqual(captured?.documentNumber, "12345678909")
    }

    func test_submitPaymentData_whenCalledWithDocumentTypeSelected_shouldPassDocumentType() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setIdentificationTypesResult(.success([IdentificationTypeStub.cpf]))
        await sut.viewModel.loadIdentificationTypes()
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))

        // Act
        _ = try await sut.viewModel.submitPaymentData(nil, cardFormData: CardFormDataStub.validForm)

        // Assert
        let captured = await sut.service.capturedCardParams
        XCTAssertEqual(captured?.documentType, IdentificationTypeStub.cpf.id)
    }

    func test_submitPaymentData_whenDocumentTypeIsNil_shouldReturnOnlyToken() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))
        // selectTypeDocument starts nil (no identificationTypes loaded)

        // Act
        let result = try await sut.viewModel.submitPaymentData(nil, cardFormData: CardFormDataStub.validForm)

        // Assert
        XCTAssertEqual(result.token, CardTokenStub.valid.token)
        XCTAssertNil(result.transactionAmount)
        XCTAssertNil(result.paymentMethodId)
        XCTAssertNil(result.paymentTypeId)
        XCTAssertNil(result.issuerId)
        XCTAssertNil(result.payer)
    }

    func test_submitPaymentData_whenDocumentTypeIsSelected_shouldIncludePayer() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setIdentificationTypesResult(.success([IdentificationTypeStub.cpf]))
        await sut.viewModel.loadIdentificationTypes()
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))
        var cardForm = CardFormDataStub.validForm
        cardForm.documentHolder = "12345678900"

        // Act
        let result = try await sut.viewModel.submitPaymentData(200.0, cardFormData: cardForm)

        // Assert
        XCTAssertEqual(result.payer?.type, IdentificationTypeStub.cpf.type)
        XCTAssertEqual(result.payer?.number, "12345678900")
    }

    func test_submitPaymentData_whenDocumentTypeIsSelected_shouldSetTransactionAmountAndInstallment() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setIdentificationTypesResult(.success([IdentificationTypeStub.cpf]))
        await sut.viewModel.loadIdentificationTypes()
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))

        // Act
        let result = try await sut.viewModel.submitPaymentData(350.0, cardFormData: CardFormDataStub.validForm)

        // Assert
        XCTAssertEqual(result.transactionAmount, 350.0)
        XCTAssertEqual(result.installment, 1)
        XCTAssertEqual(result.token, CardTokenStub.valid.token)
    }

    func test_submitPaymentData_whenBinDataIsAvailable_shouldIncludePaymentMethodAndTypeIds() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setIdentificationTypesResult(.success([IdentificationTypeStub.cpf]))
        await sut.viewModel.loadIdentificationTypes()
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.visa))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binData)
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))

        // Act
        let result = try await sut.viewModel.submitPaymentData(100.0, cardFormData: CardFormDataStub.validForm)

        // Assert
        XCTAssertEqual(result.paymentMethodId, "visa")
        XCTAssertEqual(result.paymentTypeId, "credit_card")
    }

    func test_submitPaymentData_whenBinDataIsNil_shouldHaveNilPaymentMethodIds() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setIdentificationTypesResult(.success([IdentificationTypeStub.cpf]))
        await sut.viewModel.loadIdentificationTypes()
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))
        // No bin fetch triggered — binData remains nil

        // Act
        let result = try await sut.viewModel.submitPaymentData(100.0, cardFormData: CardFormDataStub.validForm)

        // Assert
        XCTAssertNil(result.paymentMethodId)
        XCTAssertNil(result.paymentTypeId)
        XCTAssertNil(result.issuerId)
    }

    func test_submitPaymentData_whenBinDataHasIssuer_shouldIncludeIssuerId() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setIdentificationTypesResult(.success([IdentificationTypeStub.cpf]))
        await sut.viewModel.loadIdentificationTypes()
        let binDataWithIssuer = CardBinData(
            paymentMethod: CardBinDataStub.visa.paymentMethod,
            issuer: IssuerStub.bradesco,
            installment: nil
        )
        await sut.service.setFetchBinDataResult(.success(binDataWithIssuer))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binData)
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))

        // Act
        let result = try await sut.viewModel.submitPaymentData(100.0, cardFormData: CardFormDataStub.validForm)

        // Assert
        XCTAssertEqual(result.issuerId, IssuerStub.bradesco.id)
    }

    func test_retryBinFetch_whenCalledTwice_withNetworkError_shouldShowSnackbarBothTimes() async {
        // Arrange — initial fetch fails
        let sut = self.makeSUT()
        let networkError = MercadoPagoCheckoutError(code: .networkConnectionFailed, _localizedDescription: "", location: .paymentMethods)
        await sut.service.setFetchBinDataResult(.failure(networkError))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binNetworkError)

        // First retry fails → showSnackbar becomes true
        await sut.service.setFetchBinDataResult(.failure(networkError))
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

        await sut.service.setFetchBinDataResult(.failure(networkError))
        sut.viewModel.retryBinFetch()
        await fulfillment(of: [exp], timeout: 1.0)

        // Assert — snackbar was reset then re-triggered
        XCTAssertEqual(capturedValues, [false, true])
    }
}
