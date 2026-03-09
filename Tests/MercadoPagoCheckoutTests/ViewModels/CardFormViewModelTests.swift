//
//  CardFormViewModelTests.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 25/02/26.
//

import Combine
@testable import CoreMethods
@testable import MercadoPagoCheckout
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

    func test_init_fetchBinErrorShouldBeNil() {
        // Arrange / Act
        let sut = self.makeSUT()

        // Assert
        XCTAssertNil(sut.viewModel.fetchBinError)
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

    // MARK: - onCardNumberChange

    func test_onCardNumberChange_whenDigitsLessThan8_shouldNotFetchBinData() {
        // Arrange
        let sut = self.makeSUT()

        // Act — synchronous: no task created for < 8 digits
        sut.viewModel.onCardNumberChange("1234567")

        // Assert
        XCTAssertNil(sut.viewModel.binData)
        XCTAssertNil(sut.viewModel.fetchBinError)
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
        XCTAssertNil(sut.viewModel.fetchBinError)
    }

    func test_onCardNumberChange_whenDigitsReach8_withError_shouldSetApiError() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.failure(BinFetchError.paymentMethodNotAllowed("visa")))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$fetchBinError)

        // Assert
        XCTAssertNotNil(sut.viewModel.fetchBinError)
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
        XCTAssertNil(sut.viewModel.fetchBinError)
    }

    func test_onCardNumberChange_whenSameBINCalledTwice_shouldNotRefetch() async {
        // Arrange — first call fails
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.failure(BinFetchError.paymentMethodNotAllowed("visa")))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$fetchBinError)
        XCTAssertNotNil(sut.viewModel.fetchBinError)

        // Change result to success, but call with same BIN
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.visa))

        // Act — same BIN is rejected synchronously before any task is created
        sut.viewModel.onCardNumberChange("12345678")

        // Assert — state unchanged
        XCTAssertNotNil(sut.viewModel.fetchBinError)
        XCTAssertNil(sut.viewModel.binData)
    }

    func test_onCardNumberChange_whenDifferentBINAfterError_shouldRefetchAndClearError() async {
        // Arrange — first BIN fails
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.failure(BinFetchError.paymentMethodNotAllowed("visa")))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$fetchBinError)

        // Act — different BIN with success
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.master))
        sut.viewModel.onCardNumberChange("87654321")
        await self.waitForChange(sut.viewModel.$binData)

        // Assert
        XCTAssertNil(sut.viewModel.fetchBinError)
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

    // MARK: - isSecurityCodeOptional

    func test_isSecurityCodeOptional_whenBinDataIsNil_shouldReturnFalse() {
        // Arrange / Act
        let sut = self.makeSUT()

        // Assert
        XCTAssertFalse(sut.viewModel.isSecurityCodeOptional)
    }

    func test_isSecurityCodeOptional_whenCardInfoIsNil_shouldReturnFalse() async {
        // Arrange — visa stub has card: nil
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.visa))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binData)

        // Assert
        XCTAssertFalse(sut.viewModel.isSecurityCodeOptional)
    }

    func test_isSecurityCodeOptional_whenSecurityCodeLengthIsPositive_shouldReturnFalse() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.visaWithCVV))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binData)

        // Assert
        XCTAssertFalse(sut.viewModel.isSecurityCodeOptional)
    }

    func test_isSecurityCodeOptional_whenSecurityCodeLengthIsZero_shouldReturnTrue() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.visaOptionalCVV))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binData)

        // Assert
        XCTAssertTrue(sut.viewModel.isSecurityCodeOptional)
    }

    func test_isSecurityCodeOptional_whenBinDataCleared_shouldReturnFalse() async {
        // Arrange — start with optional CVV
        let sut = self.makeSUT()
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.visaOptionalCVV))
        sut.viewModel.onCardNumberChange("12345678")
        await self.waitForChange(sut.viewModel.$binData)
        XCTAssertTrue(sut.viewModel.isSecurityCodeOptional)

        // Act — clearing below 8 digits resets binData to nil synchronously
        sut.viewModel.onCardNumberChange("123")

        // Assert
        XCTAssertNil(sut.viewModel.binData)
        XCTAssertFalse(sut.viewModel.isSecurityCodeOptional)
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
}
