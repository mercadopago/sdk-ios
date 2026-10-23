//
//  EmailFieldStateTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import XCTest

final class EmailFieldStateTests: XCTestCase {
    func test_init_withOtherItemType_shouldReturnNil() {
        // Arrange
        let item = ReviewConfirmItem(
            type: "payment_method",
            label: "Medio de pago",
            value: "Visa •••• 4567",
            button: nil
        )

        // Act / Assert
        XCTAssertNil(EmailFieldState(item: item))
    }

    func test_init_withPayerEmailWithoutValue_shouldReturnNil() {
        // Arrange
        let item = ReviewConfirmItem(type: "payer_email", label: "E-mail", value: nil, button: nil)

        // Act / Assert
        XCTAssertNil(EmailFieldState(item: item))
    }

    func test_init_withPayerEmailWithoutChangeLabel_shouldHaveNilChangeLabel() throws {
        // Arrange
        let item = ReviewConfirmItem(type: "payer_email", label: "E-mail", value: "t****@g****.com", button: nil)

        // Act
        let state = try XCTUnwrap(EmailFieldState(item: item))

        // Assert
        XCTAssertEqual(state.label, "E-mail")
        XCTAssertEqual(state.maskedEmail, "t****@g****.com")
        XCTAssertNil(state.changeLabel)
    }

    func test_init_withPayerEmailWithChangeLabel_shouldCopyChangeLabel() throws {
        // Arrange
        let item = ReviewConfirmItem(
            type: "payer_email",
            label: "E-mail",
            value: "t****@g****.com",
            button: .init(label: "Modificar")
        )

        // Act
        let state = try XCTUnwrap(EmailFieldState(item: item))

        // Assert
        XCTAssertEqual(state.maskedEmail, "t****@g****.com")
        XCTAssertEqual(state.changeLabel, "Modificar")
    }
}
