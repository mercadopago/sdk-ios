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
    // MARK: - payerEmail

    func test_payerEmail_withPaymentOrderPayer_shouldReturnEmail() {
        // Arrange
        let sut = self.makePaymentSUT(payer: MPPayer(email: "buyer@mail.com"))

        // Act / Assert
        XCTAssertEqual(sut.payerEmail, "buyer@mail.com")
    }

    func test_payerEmail_withCardTransactionOrderPayer_shouldReturnEmail() {
        // Arrange
        let order = MPOrder(orderId: "ORD01", clientToken: "seller_client_token", amount: 100, payer: MPPayer(email: "card@mail.com"))
        let configuration = MPCheckoutConfiguration<MPPaymentData.CardTransaction>(
            type: .cardTransaction(order: order),
            paymentMethod: [.card()]
        )
        let sut = PaymentBrickViewModel(configuration: configuration)

        // Act / Assert
        XCTAssertEqual(sut.payerEmail, "card@mail.com")
    }

    func test_payerEmail_withoutPayer_shouldReturnEmpty() {
        // Arrange
        let sut = self.makePaymentSUT(payer: nil)

        // Act / Assert
        XCTAssertEqual(sut.payerEmail, "")
    }

    func test_payerEmail_withSaveCard_shouldReturnEmpty() {
        // Arrange
        let configuration = MPCheckoutConfiguration<MPPaymentData.CardSave>(
            type: .saveCard,
            paymentMethod: [.card()]
        )
        let sut = PaymentBrickViewModel(configuration: configuration)

        // Act / Assert
        XCTAssertEqual(sut.payerEmail, "")
    }

    // MARK: - makeEmailViewModel

    func test_makeEmailViewModel_shouldPrefillEmailFromConfiguration() {
        // Arrange
        let sut = self.makePaymentSUT(payer: MPPayer(email: "buyer@mail.com"))

        // Act
        let emailViewModel = sut.makeEmailViewModel()

        // Assert
        XCTAssertEqual(emailViewModel.email, "buyer@mail.com")
        XCTAssertTrue(emailViewModel.isEmailValid)
    }

    func test_makeEmailViewModel_withoutPayer_shouldStartEmptyAndInvalid() {
        // Arrange
        let sut = self.makePaymentSUT(payer: nil)

        // Act
        let emailViewModel = sut.makeEmailViewModel()

        // Assert
        XCTAssertEqual(emailViewModel.email, "")
        XCTAssertFalse(emailViewModel.isEmailValid)
    }

    // MARK: - Helpers

    private func makePaymentSUT(payer: MPPayer?) -> PaymentBrickViewModel<MPPaymentData.Payment> {
        let order = MPOrder(orderId: "ORD01", clientToken: "seller_client_token", amount: 100, payer: payer ?? MPPayer(email: ""))
        let configuration = MPCheckoutConfiguration<MPPaymentData.Payment>(
            type: .payment(order: order),
            paymentMethod: [.card()]
        )
        return PaymentBrickViewModel(configuration: configuration)
    }
}
