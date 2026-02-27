//
//  CardFormViewModelTests.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 25/02/26.
//

import XCTest
import Combine
@testable import MercadoPagoCheckout
@testable import CoreMethods

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
        cancellables.removeAll()
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
    }

    // MARK: - Helpers

    private func makeSUT() -> SUT {
        let service = MockCheckoutService()
        let configuration = MercadoPagoCheckout.CheckoutConfiguration(
            type: .cardForm(cardFormConfiguration: .init()),
            paymentMethod: [.card(cardTypes: [.credit, .debit, .prepaid])]
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
            .store(in: &cancellables)
        await fulfillment(of: [exp], timeout: timeout)
    }

    // MARK: - Init

    func test_init_screenStateShouldBeLoading() {
        // Arrange / Act
        let sut = makeSUT()

        // Assert
        XCTAssertEqual(sut.viewModel.screenState, .loading)
    }

    func test_init_binDataShouldBeNil() {
        // Arrange / Act
        let sut = makeSUT()

        // Assert
        XCTAssertNil(sut.viewModel.binData)
    }

    func test_init_hasCardNumberApiErrorShouldBeFalse() {
        // Arrange / Act
        let sut = makeSUT()

        // Assert
        XCTAssertFalse(sut.viewModel.hasCardNumberApiError)
    }

    // MARK: - loadIdentificationTypes

    func test_loadIdentificationTypes_whenSuccess_shouldSetReadyState() async {
        // Arrange
        let sut = makeSUT()
        await sut.service.setIdentificationTypesResult(.success([IdentificationTypeStub.cpf]))

        // Act
        await sut.viewModel.loadIdentificationTypes()

        // Assert
        XCTAssertEqual(sut.viewModel.screenState, .ready)
    }

    func test_loadIdentificationTypes_whenSuccess_withTypes_shouldUpdateSelectTypeDocument() async {
        // Arrange
        let sut = makeSUT()
        await sut.service.setIdentificationTypesResult(.success([IdentificationTypeStub.cpf, IdentificationTypeStub.cnpj]))

        // Act
        await sut.viewModel.loadIdentificationTypes()

        // Assert
        XCTAssertEqual(sut.viewModel.selectTypeDocument, IdentificationTypeStub.cpf)
    }

    func test_loadIdentificationTypes_whenSuccess_withEmptyTypes_shouldKeepDefaultDocument() async {
        // Arrange
        let sut = makeSUT()
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
        let sut = makeSUT()
        await sut.service.setIdentificationTypesResult(.failure(MockCheckoutService.MockError.resultNotSet))

        // Act
        await sut.viewModel.loadIdentificationTypes()

        // Assert
        XCTAssertEqual(sut.viewModel.screenState, .ready)
    }

    func test_loadIdentificationTypes_whenError_shouldKeepDefaultDocument() async {
        // Arrange
        let sut = makeSUT()
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
        let sut = makeSUT()

        // Act — synchronous: no task created for < 8 digits
        sut.viewModel.onCardNumberChange("1234567")

        // Assert
        XCTAssertNil(sut.viewModel.binData)
        XCTAssertFalse(sut.viewModel.hasCardNumberApiError)
    }

    func test_onCardNumberChange_whenDigitsReach8_withSuccess_shouldSetBinData() async {
        // Arrange
        let sut = makeSUT()
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.visa))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await waitForChange(sut.viewModel.$binData)

        // Assert
        XCTAssertEqual(sut.viewModel.binData, CardBinDataStub.visa)
        XCTAssertFalse(sut.viewModel.hasCardNumberApiError)
    }

    func test_onCardNumberChange_whenDigitsReach8_withError_shouldSetApiError() async {
        // Arrange
        let sut = makeSUT()
        await sut.service.setFetchBinDataResult(.failure(MockCheckoutService.MockError.resultNotSet))

        // Act
        sut.viewModel.onCardNumberChange("12345678")
        await waitForChange(sut.viewModel.$hasCardNumberApiError)

        // Assert
        XCTAssertTrue(sut.viewModel.hasCardNumberApiError)
        XCTAssertNil(sut.viewModel.binData)
    }

    func test_onCardNumberChange_whenClearedBelow8Digits_shouldClearBinDataAndError() async {
        // Arrange
        let sut = makeSUT()
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.visa))
        sut.viewModel.onCardNumberChange("12345678")
        await waitForChange(sut.viewModel.$binData)

        // Act — clearing to below 8 digits is synchronous
        sut.viewModel.onCardNumberChange("123")

        // Assert
        XCTAssertNil(sut.viewModel.binData)
        XCTAssertFalse(sut.viewModel.hasCardNumberApiError)
    }

    func test_onCardNumberChange_whenSameBINCalledTwice_shouldNotRefetch() async {
        // Arrange — first call fails
        let sut = makeSUT()
        await sut.service.setFetchBinDataResult(.failure(MockCheckoutService.MockError.resultNotSet))
        sut.viewModel.onCardNumberChange("12345678")
        await waitForChange(sut.viewModel.$hasCardNumberApiError)
        XCTAssertTrue(sut.viewModel.hasCardNumberApiError)

        // Change result to success, but call with same BIN
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.visa))

        // Act — same BIN is rejected synchronously before any task is created
        sut.viewModel.onCardNumberChange("12345678")

        // Assert — state unchanged
        XCTAssertTrue(sut.viewModel.hasCardNumberApiError)
        XCTAssertNil(sut.viewModel.binData)
    }

    func test_onCardNumberChange_whenDifferentBINAfterError_shouldRefetchAndClearError() async {
        // Arrange — first BIN fails
        let sut = makeSUT()
        await sut.service.setFetchBinDataResult(.failure(MockCheckoutService.MockError.resultNotSet))
        sut.viewModel.onCardNumberChange("12345678")
        await waitForChange(sut.viewModel.$hasCardNumberApiError)

        // Act — different BIN with success
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.master))
        sut.viewModel.onCardNumberChange("87654321")
        await waitForChange(sut.viewModel.$binData)

        // Assert
        XCTAssertFalse(sut.viewModel.hasCardNumberApiError)
        XCTAssertEqual(sut.viewModel.binData, CardBinDataStub.master)
    }

    func test_onCardNumberChange_whenFormattedCardNumber_shouldExtractBINCorrectly() async {
        // Arrange — formatted number "1234 5678 9012 3456"
        let sut = makeSUT()
        await sut.service.setFetchBinDataResult(.success(CardBinDataStub.visa))

        // Act
        sut.viewModel.onCardNumberChange("1234 5678 9012 3456")
        await waitForChange(sut.viewModel.$binData)

        // Assert — BIN extracted from digits only (12345678)
        XCTAssertEqual(sut.viewModel.binData, CardBinDataStub.visa)
    }
}
