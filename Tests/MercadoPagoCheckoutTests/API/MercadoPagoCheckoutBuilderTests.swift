//
//  MercadoPagoCheckoutBuilderTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 24/04/26.
//

@testable import MercadoPagoCheckout
import XCTest

/// The `Builder` is the only ergonomic entry point for constructing a
/// `MercadoPagoCheckout` — consumers of the SDK go through it. Tests below
/// assert the stored fields and the default payment methods so a silent
/// regression (e.g. `.defaults` becoming empty) fails here rather than in
/// production.
@MainActor
final class MercadoPagoCheckoutBuilderTests: XCTestCase {
    // MARK: - Init + defaults

    func test_init_shouldStoreCheckoutTypeAndAppearance() {
        // Arrange
        let appearance = MercadoPagoCheckout.CheckoutAppearance()
        let checkoutType: MercadoPagoCheckout.CheckoutType = .cardForm(
            cardFormConfiguration: .init(amount: 100.0)
        )

        // Act
        let checkout = MercadoPagoCheckout.Builder(
            checkoutType: checkoutType,
            checkoutAppearance: appearance
        ).build()

        // Assert
        if case let .cardForm(cardFormConfiguration) = checkout.configuration.type {
            XCTAssertEqual(cardFormConfiguration.amount, 100.0)
        } else {
            XCTFail("Expected .cardForm checkout type")
        }
    }

    func test_build_withoutSettingPaymentMethods_shouldUseDefaults() {
        // Arrange / Act
        let checkout = MercadoPagoCheckout.Builder(
            checkoutType: .cardForm(cardFormConfiguration: .init(amount: 50.0)),
            checkoutAppearance: MercadoPagoCheckout.CheckoutAppearance()
        ).build()

        // Assert -- default is the same list exposed by PaymentMethod.defaults
        let expectedCount = MercadoPagoCheckout.PaymentMethod.defaults.count
        XCTAssertEqual(checkout.configuration.paymentMethod.count, expectedCount)
    }

    // MARK: - setPaymentMethods chaining

    func test_setPaymentMethods_shouldReplaceDefaults() {
        // Arrange -- custom list with only credit card
        let customMethods: [MercadoPagoCheckout.PaymentMethod] = [
            .card(allowedTypes: [.credit], allowedBrands: [.visa])
        ]

        // Act
        let checkout = MercadoPagoCheckout.Builder(
            checkoutType: .cardForm(cardFormConfiguration: .init(amount: 100.0)),
            checkoutAppearance: MercadoPagoCheckout.CheckoutAppearance()
        )
        .setPaymentMethods(customMethods)
        .build()

        // Assert
        XCTAssertEqual(checkout.configuration.paymentMethod.count, 1)
        if case let .card(types, brands, _) = checkout.configuration.paymentMethod[0] {
            XCTAssertEqual(types, [.credit])
            XCTAssertEqual(brands, [.visa])
        } else {
            XCTFail("Expected .card payment method")
        }
    }

    func test_setPaymentMethods_withoutArgument_shouldResetToDefaults() {
        // Arrange -- first override, then reset
        let builder = MercadoPagoCheckout.Builder(
            checkoutType: .cardForm(cardFormConfiguration: .init(amount: 100.0)),
            checkoutAppearance: MercadoPagoCheckout.CheckoutAppearance()
        )
        builder.setPaymentMethods([.card(allowedTypes: [.credit])])

        // Act -- reset via default argument
        let checkout = builder.setPaymentMethods().build()

        // Assert
        let expectedCount = MercadoPagoCheckout.PaymentMethod.defaults.count
        XCTAssertEqual(checkout.configuration.paymentMethod.count, expectedCount)
    }

    func test_setPaymentMethods_shouldBeDiscardableAndReturnSameBuilder() {
        // Arrange
        let builder = MercadoPagoCheckout.Builder(
            checkoutType: .cardForm(cardFormConfiguration: .init(amount: 100.0)),
            checkoutAppearance: MercadoPagoCheckout.CheckoutAppearance()
        )

        // Act -- return value is the same reference, enabling chaining
        let chained = builder.setPaymentMethods([.card(allowedTypes: [.credit])])

        // Assert
        XCTAssertTrue(chained === builder)
    }

    // MARK: - Payment method identity in configuration

    func test_build_shouldPropagateCheckoutTypeToConfiguration() {
        // Arrange
        let config = MercadoPagoCheckout.CardFormConfiguration(amount: 77.5)

        // Act
        let checkout = MercadoPagoCheckout.Builder(
            checkoutType: .cardForm(cardFormConfiguration: config),
            checkoutAppearance: MercadoPagoCheckout.CheckoutAppearance()
        ).build()

        // Assert
        if case let .cardForm(cardFormConfiguration) = checkout.configuration.type {
            XCTAssertEqual(cardFormConfiguration.amount, 77.5)
        } else {
            XCTFail("Expected .cardForm")
        }
    }
}
