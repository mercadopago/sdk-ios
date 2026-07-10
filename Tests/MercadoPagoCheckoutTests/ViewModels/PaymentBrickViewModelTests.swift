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
            type: .payment(order: order),
            paymentMethod: [.card()]
        )
        if let repo = orderRepository {
            return PaymentBrickViewModel(configuration: configuration, orderTransactionUseCase: OrderTransactionUseCase(repository: repo))
        }
        return PaymentBrickViewModel(configuration: configuration)
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
        paymentTypeId: String = "credit_card"
    ) -> OrderTransactionProcessData {
        OrderTransactionProcessData(
            id: "ORD01",
            status: status,
            statusDetail: "accredited",
            totalAmount: "100.00",
            payments: [
                OrderTransactionProcessData.Payment(
                    id: "PAY01",
                    status: status,
                    statusDetail: "accredited",
                    amount: "100.00",
                    paymentMethodId: paymentMethodId,
                    paymentTypeId: paymentTypeId,
                    installments: 1
                )
            ]
        )
    }
}
