//
//  MercadoPagoCheckoutResultOrderTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import XCTest

final class MercadoPagoCheckoutResultOrderTests: XCTestCase {
    func test_processedOrder_WhenRejected_ShouldReturnPaymentRejectedError() {
        let payment = MPPaymentData.Payment(orderId: "1", orderStatus: "rejected", transactionAmount: 10)

        guard case let .error(error) = MercadoPagoCheckoutResult.processedOrder(payment, orderStatus: payment.orderStatus) else {
            return XCTFail("A rejected order should be reported as an error")
        }
        XCTAssertEqual(error.code, .paymentRejected)
    }

    func test_processedOrder_WhenNotRejected_ShouldReturnSuccess() {
        for status in ["processed", "action_required", ""] {
            let transaction = MPPaymentData.CardTransaction(orderStatus: status)

            guard case let .success(data) = MercadoPagoCheckoutResult.processedOrder(transaction, orderStatus: status) else {
                return XCTFail("Status \(status) should be reported as success")
            }
            XCTAssertEqual(data.orderStatus, status)
        }
    }
}
