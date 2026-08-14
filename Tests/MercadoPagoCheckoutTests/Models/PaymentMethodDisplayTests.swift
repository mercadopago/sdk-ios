//
//  PaymentMethodDisplayTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import XCTest

final class PaymentMethodDisplayTests: XCTestCase {
    func test_init_withPaymentMethodItem_shouldCopyFields() throws {
        // Arrange
        let item = ReviewConfirmItem(
            type: "payment_method",
            label: "Medio de pago",
            value: "Santander •••• 4567",
            changeLabel: "Modificar"
        )

        // Act
        let display = try XCTUnwrap(PaymentMethodDisplay(item: item))

        // Assert
        XCTAssertEqual(display.label, "Medio de pago")
        XCTAssertEqual(display.value, "Santander •••• 4567")
        XCTAssertEqual(display.changeLabel, "Modificar")
    }

    func test_init_withOtherItemType_shouldReturnNil() {
        // Arrange
        let item = ReviewConfirmItem(type: "payer_email", label: "E-mail", value: "t***@g***.com", changeLabel: nil)

        // Act / Assert
        XCTAssertNil(PaymentMethodDisplay(item: item))
    }
}
