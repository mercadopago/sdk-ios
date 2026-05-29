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
/// assert the stored fields and the default payment method configuration so a
/// silent regression (e.g. configuration not persisting) fails here rather than
/// in production. The generic T parameter is also exercised to confirm that
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

    func test_build_withoutSettingPaymentMethodConfiguration_shouldHaveDefaultConfiguration() {
        let checkout = MercadoPagoCheckout.Builder(
            checkoutType: .cardTransaction(order: .init(amount: 50.0, payer: .init(email: "test@mp.com"))),
            checkoutAppearance: .init()
        ).build()

        XCTAssertEqual(checkout.configuration.paymentMethod.count, 1)
        if case let .card(excludedTypes, excludedBrands, installment) = checkout.configuration.paymentMethod[0] {
            XCTAssertTrue(excludedTypes.isEmpty)
            XCTAssertTrue(excludedBrands.isEmpty)
            XCTAssertNotNil(installment)
        } else {
            XCTFail("Expected .card payment method config")
        }
    }

    func test_setPaymentMethodConfiguration_shouldStoreConfiguration() {
        let customConfig: [MPPaymentMethodConfig] = [
            .card(excludedTypes: [.credit], excludedBrands: [.visa])
        ]

        let checkout = MercadoPagoCheckout.Builder(
            checkoutType: .cardTransaction(order: .init(amount: 50.0, payer: .init(email: "test@mp.com"))),
            checkoutAppearance: .init()
        )
        .setPaymentMethodConfiguration(customConfig)
        .build()

        XCTAssertEqual(checkout.configuration.paymentMethod.count, 1)
        if case let .card(types, brands, _) = checkout.configuration.paymentMethod[0] {
            XCTAssertEqual(types, [.credit])
            XCTAssertEqual(brands, [.visa])
        } else {
            XCTFail("Expected .card payment method config")
        }
    }

    func test_setPaymentMethodConfiguration_withNoArgument_shouldResetToEmpty() {
        let builder = MercadoPagoCheckout.Builder(
            checkoutType: .cardTransaction(order: .init(amount: 50.0, payer: .init(email: "test@mp.com"))),
            checkoutAppearance: .init()
        )
        builder.setPaymentMethodConfiguration([.card(excludedTypes: [.credit])])

        let checkout = builder.setPaymentMethodConfiguration().build()

        XCTAssertEqual(checkout.configuration.paymentMethod.count, 0)
    }

    func test_setPaymentMethodConfiguration_shouldBeDiscardableAndReturnSameBuilder() {
        let builder = MercadoPagoCheckout.Builder(
            checkoutType: .cardTransaction(order: .init(amount: 50.0, payer: .init(email: "test@mp.com"))),
            checkoutAppearance: .init()
        )

        let chained = builder.setPaymentMethodConfiguration([.card(excludedTypes: [.credit])])

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

    func test_saveCard_build_withoutSettingPaymentMethodConfiguration_shouldHaveDefaultConfiguration() {
        let checkout = MercadoPagoCheckout.Builder(
            checkoutType: .saveCard,
            checkoutAppearance: .init()
        ).build()

        XCTAssertEqual(checkout.configuration.paymentMethod.count, 1)
        if case let .card(excludedTypes, excludedBrands, installment) = checkout.configuration.paymentMethod[0] {
            XCTAssertTrue(excludedTypes.isEmpty)
            XCTAssertTrue(excludedBrands.isEmpty)
            XCTAssertNotNil(installment)
        } else {
            XCTFail("Expected .card payment method config")
        }
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

    func test_cardTransaction_checkoutType_carriesOrderAmount() {
        let checkoutType = MercadoPagoCheckout<MPPaymentData.CardTransaction>.CheckoutType.cardTransaction(
            order: .init(amount: 77.5, payer: .init(email: "test@mp.com"))
        )
        guard case let .cardTransaction(order) = checkoutType.kind else {
            return XCTFail("Expected .cardTransaction kind")
        }
        XCTAssertEqual(order.amount, 77.5)
    }

    func test_saveCard_checkoutType_hasSaveCardKind() {
        let checkoutType = MercadoPagoCheckout<MPPaymentData.CardSave>.CheckoutType.saveCard
        guard case .saveCard = checkoutType.kind else {
            return XCTFail("Expected .saveCard kind")
        }
    }
}
