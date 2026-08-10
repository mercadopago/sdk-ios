//
//  PaymentBrickViewModelTests.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 02/06/26.
//

@testable import MercadoPagoCheckout
import XCTest

@MainActor
final class PaymentBrickViewModelTests: XCTestCase {
    // MARK: - shouldSkipSecurityCode(from:)

    func test_shouldSkipSecurityCode_whenItemHasSecurityCodeScreen_returnsFalse() {
        let sut = self.makePaymentSUT()
        let item = self.makeSavedCardItem(withSecurityCode: true)
        XCTAssertFalse(sut.shouldSkipSecurityCode(from: item))
    }

    func test_shouldSkipSecurityCode_whenItemHasNoSecurityCodeScreen_returnsTrue() {
        let sut = self.makePaymentSUT()
        let item = self.makeSavedCardItem(withSecurityCode: false)
        XCTAssertTrue(sut.shouldSkipSecurityCode(from: item))
    }

    // MARK: - markScreenPresented / screensVisited

    func test_screensVisited_initiallyEmpty() {
        let sut = self.makePaymentSUT()
        XCTAssertTrue(sut.screensVisited.isEmpty)
    }

    func test_markScreenPresented_paymentMethodSelector_addsScreen() {
        let sut = self.makePaymentSUT()
        sut.markScreenPresented(.paymentMethodSelector)
        XCTAssertEqual(sut.screensVisited, [.paymentMethodSelector])
    }

    func test_markScreenPresented_preservesOrderOfVisitedScreens() {
        let sut = self.makePaymentSUT()
        sut.markScreenPresented(.paymentMethodSelector)
        sut.markScreenPresented(.installments)
        XCTAssertEqual(sut.screensVisited, [.paymentMethodSelector, .installments])
    }

    func test_markScreenPresented_doesNotAddDuplicates() {
        let sut = self.makePaymentSUT()
        sut.markScreenPresented(.paymentMethodSelector)
        sut.markScreenPresented(.paymentMethodSelector)
        XCTAssertEqual(sut.screensVisited.count, 1)
    }

    // MARK: - processOrder

    func test_processOrder_onSuccess_returnsMappedPayment() async throws {
        let repository = MockOrderTransactionRepository()
        let sut = self.makePaymentSUT(orderRepository: repository)
        await repository.setResult(.success(self.makeProcessData()))

        let result = try await sut.processOrder(params: self.makeOrderParams())

        XCTAssertEqual(result.orderId, "ORD01")
        XCTAssertEqual(result.orderStatus, "approved")
        XCTAssertEqual(result.paymentMethodId, "visa")
        XCTAssertEqual(result.paymentTypeId, "credit_card")
    }

    func test_processOrder_onSuccess_transactionAmountParsedFromServiceResponse() async throws {
        let repository = MockOrderTransactionRepository()
        let sut = self.makePaymentSUT(orderRepository: repository)
        await repository.setResult(.success(self.makeProcessData(totalAmount: "250.00")))

        let result = try await sut.processOrder(params: self.makeOrderParams())

        XCTAssertEqual(result.transactionAmount, 250)
    }

    func test_processOrder_onRepositoryError_throws() async {
        let repository = MockOrderTransactionRepository()
        let sut = self.makePaymentSUT(orderRepository: repository)
        let error = MercadoPagoCheckoutError(code: .serviceError, localizedDescription: "fail", location: .orderProcess)
        await repository.setResult(.failure(error))

        do {
            _ = try await sut.processOrder(params: self.makeOrderParams())
            XCTFail("Expected throw")
        } catch let err as MercadoPagoCheckoutError {
            XCTAssertEqual(err.locationDescription, "orderProcess")
        }
    }

    func test_processOrder_skipsForNonPaymentCheckoutType_throws() async {
        let repository = MockOrderTransactionRepository()
        let configuration = MPCheckoutConfiguration<MPPaymentData.CardSave>(
            type: .saveCard,
            paymentMethod: []
        )
        let sut = PaymentBrickViewModel(
            configuration: configuration,
            orderTransactionUseCase: OrderTransactionUseCase(repository: repository)
        )

        do {
            _ = try await sut.processOrder(params: self.makeOrderParams())
            XCTFail("Expected throw")
        } catch let err as MercadoPagoCheckoutError {
            XCTAssertEqual(err.code, .unknown)
        }
        let count = await repository.callCount
        XCTAssertEqual(count, 0)
    }

    // MARK: - Helpers

    private func makePaymentSUT(
        orderRepository: MockOrderTransactionRepository? = nil
    ) -> PaymentBrickViewModel<MPPaymentData.Payment> {
        let order = MPOrder(orderId: "ORD01", clientToken: "seller_client_token")
        let configuration = MPCheckoutConfiguration<MPPaymentData.Payment>(
            type: MercadoPagoCheckout<MPPaymentData.Payment>.CheckoutType(kind: .payment(order)),
            paymentMethod: [.card()]
        )
        if let repo = orderRepository {
            return PaymentBrickViewModel(configuration: configuration, orderTransactionUseCase: OrderTransactionUseCase(repository: repo))
        }
        return PaymentBrickViewModel(configuration: configuration)
    }

    private func makeSavedCardItem(withSecurityCode: Bool) -> PaymentInitializationOutput.Item {
        let screen: SecurityCodeScreenOutput? = withSecurityCode
            ? SecurityCodeScreenOutput(
                length: 3,
                headerTitle: "Completá el código de seguridad",
                field: .init(label: "CVV", placeholder: "Ej.: 123", helper: "", error: "Completá este campo."),
                buttonLabel: "Continuar"
            )
            : nil
        return PaymentInitializationOutput.Item(
            id: "card-9999",
            title: "Mastercard •••• 6351",
            description: "Master Crédito",
            icon: .system("creditcard"),
            route: "saved_card",
            cardData: .init(
                paymentMethodId: "master",
                paymentTypeId: "credit_card",
                issuerId: 1,
                securityCodeScreen: screen
            )
        )
    }

    private func makeOrderParams() -> OrderTransactionParams {
        OrderTransactionParams(
            amount: 100,
            paymentMethodType: .card(paymentMethodId: "visa", paymentTypeId: "credit_card", token: "tok123", installments: 1)
        )
    }

    private func makeProcessData(
        status: String = "approved",
        paymentMethodId: String = "visa",
        paymentTypeId: String = "credit_card",
        totalAmount: String = "100.00"
    ) -> OrderTransactionProcessData {
        OrderTransactionProcessData(
            id: "ORD01",
            status: status,
            statusDetail: "accredited",
            totalAmount: totalAmount,
            payments: [
                OrderTransactionProcessData.Payment(
                    id: "PAY01",
                    status: status,
                    statusDetail: "accredited",
                    amount: totalAmount,
                    paymentMethodId: paymentMethodId,
                    paymentTypeId: paymentTypeId,
                    installments: 1
                )
            ]
        )
    }
}
