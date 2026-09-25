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

    func test_cardTransaction_init_shouldStoreOrderInCheckoutType() {
        let checkout = MercadoPagoCheckout.Builder(
            checkoutType: .cardTransaction(order: .init(orderId: "order-1", clientToken: "seller_client_token")),
            checkoutAppearance: .init()
        ).build()

        if case let .cardTransaction(order, _) = checkout.configuration.type.kind {
            XCTAssertEqual(order.orderId, "order-1")
        } else {
            XCTFail("Expected .cardTransaction kind")
        }
    }

    func test_build_withoutSettingPaymentMethodConfiguration_shouldHaveDefaultConfiguration() {
        let checkout = MercadoPagoCheckout.Builder(
            checkoutType: .cardTransaction(order: .init(orderId: "", clientToken: "seller_client_token")),
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
            checkoutType: .cardTransaction(order: .init(orderId: "", clientToken: "seller_client_token")),
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
            checkoutType: .cardTransaction(order: .init(orderId: "", clientToken: "seller_client_token")),
            checkoutAppearance: .init()
        )
        builder.setPaymentMethodConfiguration([.card(excludedTypes: [.credit])])

        let checkout = builder.setPaymentMethodConfiguration().build()

        XCTAssertEqual(checkout.configuration.paymentMethod.count, 0)
    }

    func test_setPaymentMethodConfiguration_shouldBeDiscardableAndReturnSameBuilder() {
        let builder = MercadoPagoCheckout.Builder(
            checkoutType: .cardTransaction(order: .init(orderId: "", clientToken: "seller_client_token")),
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

    func test_saveCard_build_shouldKeepStatusScreenDisabled() {
        let checkout = MercadoPagoCheckout.Builder(
            checkoutType: .saveCard,
            checkoutAppearance: .init()
        ).build()

        XCTAssertNil(checkout.configuration.statusScreenConfig)
    }

    /// `withStatusScreen(exit:)` is intentionally declared only on the Payment and CardTransaction
    /// constrained builder extensions. Keeping both references here provides positive compile-time
    /// API coverage; attempting the equivalent reference on a CardSave builder does not compile.
    func test_withStatusScreen_shouldBeAvailableOnlyForEligibleBuilderSpecializations() {
        let paymentBuilder = MercadoPagoCheckout.Builder(
            checkoutType: .payment(order: .init(orderId: "order-1", clientToken: "client-token")),
            checkoutAppearance: .init()
        )
        let cardTransactionBuilder = MercadoPagoCheckout.Builder(
            checkoutType: .cardTransaction(order: .init(orderId: "order-1", clientToken: "client-token")),
            checkoutAppearance: .init()
        )

        XCTAssertTrue(paymentBuilder.withStatusScreen(exit: {}) === paymentBuilder)
        XCTAssertTrue(cardTransactionBuilder.withStatusScreen(exit: {}) === cardTransactionBuilder)
    }

    // MARK: - CheckoutType type-safety

    func test_cardTransaction_checkoutType_analyticsValue() {
        let checkoutType = MercadoPagoCheckout<MPPaymentData.CardTransaction>.CheckoutType.cardTransaction(
            order: .init(orderId: "", clientToken: "seller_client_token")
        )
        XCTAssertEqual(checkoutType.analyticsValue, "card_transaction")
    }

    func test_saveCard_checkoutType_analyticsValue() {
        let checkoutType = MercadoPagoCheckout<MPPaymentData.CardSave>.CheckoutType.saveCard
        XCTAssertEqual(checkoutType.analyticsValue, "save_card")
    }

    func test_saveCard_checkoutType_hasSaveCardKind() {
        let checkoutType = MercadoPagoCheckout<MPPaymentData.CardSave>.CheckoutType.saveCard
        guard case .saveCard = checkoutType.kind else {
            return XCTFail("Expected .saveCard kind")
        }
    }
}
