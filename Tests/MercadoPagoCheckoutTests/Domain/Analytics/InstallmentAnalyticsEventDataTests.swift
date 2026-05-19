//
//  InstallmentAnalyticsEventDataTests.swift
//  MercadoPagoSDK
//

import Foundation
@testable import MercadoPagoCheckout
import XCTest

@MainActor
final class InstallmentAnalyticsEventDataTests: XCTestCase {
    // MARK: - InstallmentInitializeEventData

    func test_installmentInitializeEventData_toDictionary_shouldContainAllKeys() {
        // Arrange
        let sut = InstallmentInitializeEventData(
            checkoutType: "card_payment_brick",
            paymentMethodId: "visa",
            paymentType: "credit_card",
            selectionType: "radio_button",
            quotasCount: 6,
            transactionAmount: 500.0
        )

        // Act
        let dict = sut.toDictionary()

        // Assert
        XCTAssertEqual(dict["checkout_type"] as? String, "card_payment_brick")
        XCTAssertEqual(dict["payment_method_id"] as? String, "visa")
        XCTAssertEqual(dict["payment_type"] as? String, "credit_card")
        XCTAssertEqual(dict["selection_type"] as? String, "radio_button")
        XCTAssertEqual(dict["quotas_count"] as? Int, 6)
        XCTAssertEqual(dict["transaction_amount"] as? Double, 500.0)
    }

    func test_installmentInitializeEventData_withNilTransactionAmount_shouldOmitTransactionAmount() {
        // Arrange
        let sut = InstallmentInitializeEventData(
            checkoutType: "card_payment_brick",
            paymentMethodId: "master",
            paymentType: "debit_card",
            selectionType: "chevron",
            quotasCount: 3,
            transactionAmount: nil
        )

        // Act
        let dict = sut.toDictionary()

        // Assert
        XCTAssertNil(dict["transaction_amount"])
        XCTAssertEqual(dict["payment_method_id"] as? String, "master")
        XCTAssertEqual(dict["payment_type"] as? String, "debit_card")
        XCTAssertEqual(dict["quotas_count"] as? Int, 3)
    }

    func test_installmentInitializeEventData_withChevronSelectionType_shouldContainChevron() {
        // Arrange
        let sut = InstallmentInitializeEventData(
            checkoutType: "card_payment_brick",
            paymentMethodId: "visa",
            paymentType: "credit_card",
            selectionType: "chevron",
            quotasCount: 4,
            transactionAmount: nil
        )

        // Act
        let dict = sut.toDictionary()

        // Assert
        XCTAssertEqual(dict["selection_type"] as? String, "chevron")
    }

    // MARK: - InstallmentSelectedEventData

    func test_installmentSelectedEventData_toDictionary_shouldContainInstallments() {
        // Arrange
        let sut = InstallmentSelectedEventData(installments: 3)

        // Act
        let dict = sut.toDictionary()

        // Assert
        XCTAssertEqual(dict["installments"] as? Int, 3)
    }

    func test_installmentSelectedEventData_singleInstallment_shouldReturnOne() {
        // Arrange
        let sut = InstallmentSelectedEventData(installments: 1)

        // Act
        let dict = sut.toDictionary()

        // Assert
        XCTAssertEqual(dict["installments"] as? Int, 1)
        XCTAssertEqual(dict.keys.count, 1)
    }

    // MARK: - InstallmentSubmitEventData

    func test_installmentSubmitEventData_toDictionary_shouldContainAllKeys() {
        // Arrange
        let sut = InstallmentSubmitEventData(
            installments: 3,
            installmentAmount: 333.34,
            totalAmount: 1000.0
        )

        // Act
        let dict = sut.toDictionary()

        // Assert
        XCTAssertEqual(dict["installments"] as? Int, 3)
        XCTAssertEqual(dict["installment_amount"] as? Double, 333.34)
        XCTAssertEqual(dict["total_amount"] as? Double, 1000.0)
    }

    func test_installmentSubmitEventData_singleInstallment_shouldContainAllFields() {
        // Arrange
        let sut = InstallmentSubmitEventData(
            installments: 1,
            installmentAmount: 1000.0,
            totalAmount: 1000.0
        )

        // Act
        let dict = sut.toDictionary()

        // Assert
        XCTAssertEqual(dict["installments"] as? Int, 1)
        XCTAssertEqual(dict["installment_amount"] as? Double, 1000.0)
        XCTAssertEqual(dict["total_amount"] as? Double, 1000.0)
    }

    // MARK: - InstallmentCanceledErrorEventData

    func test_installmentCanceledErrorEventData_backPressed_shouldContainOnlyErrorType() {
        // Arrange
        let sut = InstallmentCanceledErrorEventData(errorType: "back_pressed")

        // Act
        let dict = sut.toDictionary()

        // Assert
        XCTAssertEqual(dict["error_type"] as? String, "back_pressed")
        XCTAssertEqual(dict.keys.count, 1)
    }

    func test_installmentCanceledErrorEventData_userDismissed_shouldContainOnlyErrorType() {
        // Arrange
        let sut = InstallmentCanceledErrorEventData(errorType: "user_dismissed")

        // Act
        let dict = sut.toDictionary()

        // Assert
        XCTAssertEqual(dict["error_type"] as? String, "user_dismissed")
        XCTAssertEqual(dict.keys.count, 1)
    }
}
