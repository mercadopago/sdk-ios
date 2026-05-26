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
/// production. The generic T parameter is also exercised to confirm that
/// `.cardTransaction` produces `MercadoPagoCheckout<CardTransaction>` and
/// `.saveCard` produces `MercadoPagoCheckout<CardSave>`.
@MainActor
final class MercadoPagoCheckoutBuilderTests: XCTestCase {
    // MARK: - cardTransaction flow

    func test_cardTransaction_init_shouldStoreAmountInCheckoutType() {
        let checkout = MercadoPagoCheckout.Builder(
            checkoutType: .cardTransaction(order: .init(amount: 100.0, payer: .init(email: "test@mp.com"))),
            checkoutAppearance: .init()
        ).build()

        if case let .cardTransaction(order) = checkout.configuration.type.kind {
            XCTAssertEqual(order.amount, 100.0)
        } else {
            XCTFail("Expected .cardTransaction kind")
        }
    }

    func test_cardTransaction_build_withoutSettingPaymentMethods_shouldUseDefaults() {
        let checkout = MercadoPagoCheckout.Builder(
            checkoutType: .cardTransaction(order: .init(amount: 50.0, payer: .init(email: "test@mp.com"))),
            checkoutAppearance: .init()
        ).build()

        XCTAssertEqual(
            checkout.configuration.paymentMethod.count,
            MercadoPagoCheckout<MPPaymentData.CardTransaction>.PaymentMethod.defaults.count
        )
    }

    func test_cardTransaction_setPaymentMethods_shouldReplaceDefaults() {
        let customMethods: [MercadoPagoCheckout<MPPaymentData.CardTransaction>.PaymentMethod] = [
            .card(allowedTypes: [.credit], allowedBrands: [.visa])
        ]

        let checkout = MercadoPagoCheckout.Builder(
            checkoutType: .cardTransaction(order: .init(amount: 50.0, payer: .init(email: "test@mp.com"))),
            checkoutAppearance: .init()
        )
        .setPaymentMethods(customMethods)
        .build()

        XCTAssertEqual(checkout.configuration.paymentMethod.count, 1)
        if case let .card(types, brands, _) = checkout.configuration.paymentMethod[0] {
            XCTAssertEqual(types, [.credit])
            XCTAssertEqual(brands, [.visa])
        } else {
            XCTFail("Expected .card payment method")
        }
    }

    func test_cardTransaction_setPaymentMethods_withoutArgument_shouldResetToDefaults() {
        let builder = MercadoPagoCheckout.Builder(
            checkoutType: .cardTransaction(order: .init(amount: 50.0, payer: .init(email: "test@mp.com"))),
            checkoutAppearance: .init()
        )
        builder.setPaymentMethods([.card(allowedTypes: [.credit])])
        let checkout = builder.setPaymentMethods().build()

        XCTAssertEqual(
            checkout.configuration.paymentMethod.count,
            MercadoPagoCheckout<MPPaymentData.CardTransaction>.PaymentMethod.defaults.count
        )
    }

    func test_setPaymentMethods_shouldBeDiscardableAndReturnSameBuilder() {
        let builder = MercadoPagoCheckout.Builder(
            checkoutType: .cardTransaction(order: .init(amount: 50.0, payer: .init(email: "test@mp.com"))),
            checkoutAppearance: .init()
        )
        let chained = builder.setPaymentMethods([.card(allowedTypes: [.credit])])
        XCTAssertTrue(chained === builder)
    }

    // MARK: - saveCard flow

    func test_saveCard_build_kindIsSaveCard() {
        let checkout = MercadoPagoCheckout.Builder(
            checkoutType: .saveCard,
            checkoutAppearance: .init()
        ).build()

        if case .saveCard = checkout.configuration.type.kind {} else {
            XCTFail("Expected .saveCard kind")
        }
    }

    func test_saveCard_build_withoutSettingPaymentMethods_shouldUseDefaults() {
        let checkout = MercadoPagoCheckout.Builder(
            checkoutType: .saveCard,
            checkoutAppearance: .init()
        ).build()

        XCTAssertEqual(
            checkout.configuration.paymentMethod.count,
            MercadoPagoCheckout<MPPaymentData.CardSave>.PaymentMethod.defaults.count
        )
    }

    // MARK: - CheckoutType type-safety

    func test_cardTransaction_checkoutType_analyticsValue() {
        let checkoutType = MercadoPagoCheckout<MPPaymentData.CardTransaction>.CheckoutType.cardTransaction(
            order: .init(amount: 10.0, payer: .init(email: "a@b.com"))
        )
        XCTAssertEqual(checkoutType.analyticsValue, "card_transaction")
    }

    func test_saveCard_checkoutType_analyticsValue() {
        let checkoutType = MercadoPagoCheckout<MPPaymentData.CardSave>.CheckoutType.saveCard
        XCTAssertEqual(checkoutType.analyticsValue, "save_card")
    }

    func test_cardTransaction_checkoutType_configurationAmount() {
        let checkoutType = MercadoPagoCheckout<MPPaymentData.CardTransaction>.CheckoutType.cardTransaction(
            order: .init(amount: 77.5, payer: .init(email: "test@mp.com"))
        )
        XCTAssertEqual(checkoutType.configuration.amount, 77.5)
    }

    func test_saveCard_checkoutType_configurationAmountIsZero() {
        let checkoutType = MercadoPagoCheckout<MPPaymentData.CardSave>.CheckoutType.saveCard
        XCTAssertEqual(checkoutType.configuration.amount, .zero)
    }
}
