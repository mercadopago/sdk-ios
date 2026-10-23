//
//  MPPaymentDataCardTransactionTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import XCTest

final class MPPaymentDataCardTransactionTests: XCTestCase {
    func test_encoding_ShouldNotContainCardToken() throws {
        let transaction = MPPaymentData.CardTransaction(
            transactionAmount: 100,
            installment: 3,
            paymentMethodId: "visa",
            paymentTypeId: "credit_card",
            orderId: "ORDER-1"
        )

        let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(transaction)) as? [String: Any]

        XCTAssertNil(json?["token"])
        XCTAssertEqual(json?["orderId"] as? String, "ORDER-1")
    }
}
