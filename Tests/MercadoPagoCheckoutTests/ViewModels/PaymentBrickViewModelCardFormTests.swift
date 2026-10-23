//
//  PaymentBrickViewModelCardFormTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import MPComponents
import XCTest

@MainActor
final class PaymentBrickViewModelCardFormTests: XCTestCase {
    // MARK: - Types

    typealias SUT = (
        viewModel: PaymentBrickViewModel<MPPaymentData.Payment>,
        cardFormRepository: MockCardFormInitializationRepository
    )

    // MARK: - loadCardForm(for:)

    func test_loadCardForm_onSuccess_returnsViewModelBuiltFromResult() async throws {
        let sut = self.makeSUT()
        let cardFormResult = MockCardFormInitializationRepository.makeDefault()
        sut.cardFormRepository.mockData = cardFormResult

        let cardFormViewModel = try await sut.viewModel.loadCardForm(for: self.makeNewCardItem())

        XCTAssertEqual(cardFormViewModel.initResult.title, cardFormResult.title)
    }

    func test_loadCardForm_usesInitializationAmount_notThePlaceholderTransactionAmount() async throws {
        // Regression: PaymentBrickViewModel.transactionAmount is a placeholder for the
        // "payment_brick" selector flow, independent of the CardForm's own initialization.
        // CardForm's configuration must use the amount returned by *its* initialization
        // (`result.amount`), matching how CardFormBrickViewModel derives it from
        // `self.result?.amount` — using the selector's placeholder instead would hide the amount
        // and send the wrong value to BIN lookups/analytics.
        let sut = self.makeSUT()
        sut.cardFormRepository.mockData = MockCardFormInitializationRepository.makeDefault(amount: 250)

        let cardFormViewModel = try await sut.viewModel.loadCardForm(for: self.makeNewCardItem())

        XCTAssertEqual(cardFormViewModel.footerAmount(), MPAmountData(from: Decimal(250), currencySymbol: "R$"))
    }

    func test_loadCardForm_forwardsOrderIdAndClientToken() async throws {
        let sut = self.makeSUT(orderId: "ORD42", clientToken: "tok42")

        _ = try await sut.viewModel.loadCardForm(for: self.makeNewCardItem())

        XCTAssertEqual(sut.cardFormRepository.capturedOrderId, "ORD42")
        XCTAssertEqual(sut.cardFormRepository.capturedClientToken, "tok42")
    }

    func test_loadCardForm_skipsForNonPaymentCheckoutType_throws() async {
        let repository = MockCardFormInitializationRepository()
        let configuration = MPCheckoutConfiguration<MPPaymentData.CardSave>(
            type: .saveCard,
            paymentMethod: []
        )
        let viewModel = PaymentBrickViewModel(
            configuration: configuration,
            initializeCardFormUseCase: InitializeCardFormUseCase(repository: repository)
        )
        let item = self.makeNewCardItem()

        do {
            _ = try await viewModel.loadCardForm(for: item)
            XCTFail("Expected throw")
        } catch let error as MercadoPagoCheckoutError {
            XCTAssertEqual(error.code, .unknown)
        }
        XCTAssertEqual(repository.fetchCallCount, 0)
    }

    // MARK: - Retry / failure (AC: error propagates to onError, never swallowed)

    func test_loadCardForm_onRepositoryError_retriesUpToMaxAttempts() async throws {
        let sut = self.makeSUT()
        sut.cardFormRepository.shouldThrow = true

        do {
            _ = try await sut.viewModel.loadCardForm(for: self.makeNewCardItem())
            XCTFail("Expected throw")
        } catch {
            XCTAssertEqual(sut.cardFormRepository.fetchCallCount, 2)
        }
    }

    func test_loadCardForm_onRepositoryError_throwsMercadoPagoCheckoutError() async throws {
        let sut = self.makeSUT()
        sut.cardFormRepository.shouldThrow = true

        do {
            _ = try await sut.viewModel.loadCardForm(for: self.makeNewCardItem())
            XCTFail("Expected throw")
        } catch let error as MercadoPagoCheckoutError {
            XCTAssertNotNil(error)
        } catch {
            XCTFail("Expected MercadoPagoCheckoutError, got \(error)")
        }
    }

    func test_loadCardForm_onRepositoryError_leavesSelectorScreenStateUntouched() async throws {
        // loadCardForm is independent of `screenState` (see PaymentBrick's local `cardFormViewModel`
        // @State) — the selector must stay `.ready` regardless of how the CardForm fetch resolves.
        let sut = self.makeSUT()
        try await sut.viewModel.load()
        sut.cardFormRepository.shouldThrow = true

        do {
            _ = try await sut.viewModel.loadCardForm(for: self.makeNewCardItem())
            XCTFail("Expected throw")
        } catch {
            // Expected — asserting on screenState below is the actual point of this test.
        }

        guard case .ready = sut.viewModel.screenState else {
            return XCTFail("Expected .ready untouched, got \(sut.viewModel.screenState)")
        }
    }

    // MARK: - Helpers

    private func makeSUT(
        orderId: String = "ORD01",
        clientToken: String = "token"
    ) -> SUT {
        let cardFormRepository = MockCardFormInitializationRepository()
        let order = MPOrder(orderId: orderId, clientToken: clientToken)
        let configuration = MPCheckoutConfiguration<MPPaymentData.Payment>(
            type: MercadoPagoCheckout<MPPaymentData.Payment>.CheckoutType(
                kind: .payment(order: order, sellerInfo: nil)
            ),
            paymentMethod: []
        )
        let viewModel = PaymentBrickViewModel(
            configuration: configuration,
            fetchInitializationUseCase: FetchPaymentBrickInitializationUseCase(
                repository: MockPaymentBrickRepository()
            ),
            initializeCardFormUseCase: InitializeCardFormUseCase(repository: cardFormRepository)
        )
        return (viewModel, cardFormRepository)
    }

    private func makeNewCardItem(
        notAllowedIds: [String] = [],
        notAllowedTypes: [String] = []
    ) -> PaymentInitializationOutput.Item {
        PaymentInitializationOutput.Item(
            id: "new_card",
            title: "Novo cartão",
            description: "Crédito ou pré-pago",
            icon: .system("creditcard"),
            route: "new_card",
            config: .init(paymentMethod: .init(notAllowedIds: notAllowedIds, notAllowedTypes: notAllowedTypes))
        )
    }
}
