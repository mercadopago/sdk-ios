//
//  MercadoPagoCheckoutPaymentMethodTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 24/04/26.
//

@testable import MercadoPagoCheckout
import XCTest

private typealias PaymentMethod = MPPaymentMethod
private typealias CardType = MPCardType
private typealias CardBrand = MPCardBrand

/// Covers `PaymentMethod.defaults`, the `.card` associated values, and the
/// per-element extensions `acceptedPaymentTypeIds` / `acceptedPaymentMethodIds` that
/// feed the BIN fetch request. A drift here silently changes which card
/// brands/types reach the backend.
final class MercadoPagoCheckoutPaymentMethodTests: XCTestCase {
    // MARK: - .defaults

    func test_defaults_shouldExposeASingleCardEntry() {
        let defaults = PaymentMethod.defaults

        XCTAssertEqual(defaults.count, 1)
        guard case .card = defaults[0] else {
            XCTFail("Expected .card in defaults[0]")
            return
        }
    }

    func test_defaults_cardEntry_shouldIncludeAllDefaultTypesAndBrands() {
        let defaults = PaymentMethod.defaults
        guard case let .card(types, brands, _) = defaults[0] else {
            XCTFail("Expected .card")
            return
        }

        XCTAssertEqual(types, CardType.defaults)
        XCTAssertEqual(brands, CardBrand.defaults)
    }

    // MARK: - acceptedPaymentTypeIds

    func test_acceptedPaymentTypeIds_shouldFlattenAllCardTypes() {
        let methods: [PaymentMethod] = [
            .card(allowedTypes: [.credit, .debit], allowedBrands: [.visa])
        ]

        let ids = methods.flatMap(\.acceptedPaymentTypeIds)

        XCTAssertEqual(ids, ["credit_card", "debit_card"])
    }

    func test_acceptedPaymentTypeIds_forMultipleCardEntries_shouldConcatenate() {
        let methods: [PaymentMethod] = [
            .card(allowedTypes: [.credit], allowedBrands: [.visa]),
            .card(allowedTypes: [.debit], allowedBrands: [.master])
        ]

        let ids = methods.flatMap(\.acceptedPaymentTypeIds)

        XCTAssertEqual(ids, ["credit_card", "debit_card"])
    }

    func test_acceptedPaymentTypeIds_whenEmptyList_shouldReturnEmpty() {
        let ids = [PaymentMethod]().flatMap(\.acceptedPaymentTypeIds)
        XCTAssertEqual(ids, [])
    }

    // MARK: - acceptedPaymentMethodIds

    func test_acceptedPaymentMethodIds_shouldFlattenAllBrands() {
        let methods: [PaymentMethod] = [
            .card(allowedTypes: [.credit], allowedBrands: [.visa, .master, .amex])
        ]

        let ids = methods.flatMap(\.acceptedPaymentMethodIds)

        XCTAssertEqual(ids, ["visa", "master", "amex"])
    }

    func test_acceptedPaymentMethodIds_withCustomBrand_shouldPreserveIdentifier() {
        let methods: [PaymentMethod] = [
            .card(allowedTypes: [.credit], allowedBrands: [.custom("sodexo_refeicao")])
        ]

        let ids = methods.flatMap(\.acceptedPaymentMethodIds)

        XCTAssertEqual(ids, ["sodexo_refeicao"])
    }

    func test_acceptedPaymentMethodIds_whenEmptyList_shouldReturnEmpty() {
        let ids = [PaymentMethod]().flatMap(\.acceptedPaymentMethodIds)
        XCTAssertEqual(ids, [])
    }
}
