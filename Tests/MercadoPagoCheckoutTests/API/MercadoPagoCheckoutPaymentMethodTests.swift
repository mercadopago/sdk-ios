//
//  MercadoPagoCheckoutPaymentMethodTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 24/04/26.
//

@testable import MercadoPagoCheckout
import XCTest

/// Covers `PaymentMethod.defaults`, the `.card` associated values, and the
/// array extensions `acceptedPaymentTypeIds` / `acceptedPaymentMethodIds` that
/// feed the BIN fetch request. A drift here silently changes which card
/// brands/types reach the backend.
final class MercadoPagoCheckoutPaymentMethodTests: XCTestCase {
    // MARK: - .defaults

    func test_defaults_shouldExposeASingleCardEntry() {
        // Arrange / Act
        let defaults = MercadoPagoCheckout.PaymentMethod.defaults

        // Assert -- Fase 2 baseline: only .card is in defaults. If Pix/Boleto are added
        // later, this test fails loudly and the maintainer must decide whether to update
        // consumers that assume card-only.
        XCTAssertEqual(defaults.count, 1)
        guard case .card = defaults[0] else {
            XCTFail("Expected .card in defaults[0]")
            return
        }
    }

    func test_defaults_cardEntry_shouldIncludeAllDefaultTypesAndBrands() {
        // Arrange / Act
        let defaults = MercadoPagoCheckout.PaymentMethod.defaults
        guard case let .card(types, brands, _) = defaults[0] else {
            XCTFail("Expected .card")
            return
        }

        // Assert
        XCTAssertEqual(types, MercadoPagoCheckout.CardType.defaults)
        XCTAssertEqual(brands, MercadoPagoCheckout.CardBrand.defaults)
    }

    // MARK: - acceptedPaymentTypeIds

    func test_acceptedPaymentTypeIds_shouldFlattenAllCardTypes() {
        // Arrange
        let methods: [MercadoPagoCheckout.PaymentMethod] = [
            .card(allowedTypes: [.credit, .debit], allowedBrands: [.visa])
        ]

        // Act
        let ids = methods.acceptedPaymentTypeIds

        // Assert -- backend expects "credit_card" / "debit_card" / "prepaid_card"
        XCTAssertEqual(ids, ["credit_card", "debit_card"])
    }

    func test_acceptedPaymentTypeIds_forMultipleCardEntries_shouldConcatenate() {
        // Arrange -- unusual but representable: two .card methods
        let methods: [MercadoPagoCheckout.PaymentMethod] = [
            .card(allowedTypes: [.credit], allowedBrands: [.visa]),
            .card(allowedTypes: [.debit], allowedBrands: [.master])
        ]

        // Act
        let ids = methods.acceptedPaymentTypeIds

        // Assert -- flatMap preserves order across entries
        XCTAssertEqual(ids, ["credit_card", "debit_card"])
    }

    func test_acceptedPaymentTypeIds_whenEmptyList_shouldReturnEmpty() {
        let ids: [String] = [].acceptedPaymentTypeIds
        XCTAssertEqual(ids, [])
    }

    // MARK: - acceptedPaymentMethodIds

    func test_acceptedPaymentMethodIds_shouldFlattenAllBrands() {
        // Arrange
        let methods: [MercadoPagoCheckout.PaymentMethod] = [
            .card(allowedTypes: [.credit], allowedBrands: [.visa, .master, .amex])
        ]

        // Act
        let ids = methods.acceptedPaymentMethodIds

        // Assert -- each brand maps to its paymentMethodId
        XCTAssertEqual(ids, ["visa", "master", "amex"])
    }

    func test_acceptedPaymentMethodIds_withCustomBrand_shouldPreserveIdentifier() {
        // Arrange
        let methods: [MercadoPagoCheckout.PaymentMethod] = [
            .card(allowedTypes: [.credit], allowedBrands: [.custom("sodexo_refeicao")])
        ]

        // Act
        let ids = methods.acceptedPaymentMethodIds

        // Assert
        XCTAssertEqual(ids, ["sodexo_refeicao"])
    }

    func test_acceptedPaymentMethodIds_whenEmptyList_shouldReturnEmpty() {
        let ids: [String] = [].acceptedPaymentMethodIds
        XCTAssertEqual(ids, [])
    }
}
