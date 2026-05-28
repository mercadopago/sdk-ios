//
//  MercadoPagoCheckoutPaymentMethodTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 24/04/26.
//

@testable import MercadoPagoCheckout
import XCTest

private typealias PaymentMethodConfig = MPPaymentMethodConfig
private typealias CardType = MPCardType
private typealias CardBrand = MPCardBrand

/// Covers `MPPaymentMethodConfig.card` associated values and the
/// array extensions `excludedPaymentTypeIds` / `excludedPaymentMethodIds` that
/// feed the BIN fetch request. A drift here silently changes which card
/// brands/types are excluded from the backend request.
final class MercadoPagoCheckoutPaymentMethodTests: XCTestCase {
    // MARK: - Default card (no exclusions)

    func test_cardWithNoArguments_shouldHaveEmptyExclusions() {
        guard case let .card(types, brands, _) = PaymentMethodConfig.card() else {
            XCTFail("Expected .card")
            return
        }

        XCTAssertEqual(types, [])
        XCTAssertEqual(brands, [])
    }

    // MARK: - excludedPaymentTypeIds

    func test_excludedPaymentTypeIds_shouldFlattenExcludedCardTypes() {
        let config: [PaymentMethodConfig] = [
            .card(excludedTypes: [.credit, .debit], excludedBrands: [])
        ]

        let ids = config.excludedPaymentTypeIds

        XCTAssertEqual(ids, ["credit_card", "debit_card"])
    }

    func test_excludedPaymentTypeIds_forMultipleCardEntries_shouldConcatenate() {
        let config: [PaymentMethodConfig] = [
            .card(excludedTypes: [.credit], excludedBrands: []),
            .card(excludedTypes: [.debit], excludedBrands: [])
        ]

        let ids = config.excludedPaymentTypeIds

        XCTAssertEqual(ids, ["credit_card", "debit_card"])
    }

    func test_excludedPaymentTypeIds_whenEmptyList_shouldReturnEmpty() {
        let ids = [PaymentMethodConfig]().excludedPaymentTypeIds
        XCTAssertEqual(ids, [])
    }

    func test_excludedPaymentTypeIds_whenNoExclusions_shouldReturnEmpty() {
        let config: [PaymentMethodConfig] = [.card()]

        let ids = config.excludedPaymentTypeIds

        XCTAssertEqual(ids, [])
    }

    // MARK: - excludedPaymentMethodIds

    func test_excludedPaymentMethodIds_shouldFlattenExcludedBrands() {
        let config: [PaymentMethodConfig] = [
            .card(excludedTypes: [], excludedBrands: [.visa, .master, .amex])
        ]

        let ids = config.excludedPaymentMethodIds

        XCTAssertEqual(ids, ["visa", "master", "amex"])
    }

    func test_excludedPaymentMethodIds_withCustomBrand_shouldPreserveIdentifier() {
        let config: [PaymentMethodConfig] = [
            .card(excludedTypes: [], excludedBrands: [.custom("sodexo_refeicao")])
        ]

        let ids = config.excludedPaymentMethodIds

        XCTAssertEqual(ids, ["sodexo_refeicao"])
    }

    func test_excludedPaymentMethodIds_whenEmptyList_shouldReturnEmpty() {
        let ids = [PaymentMethodConfig]().excludedPaymentMethodIds
        XCTAssertEqual(ids, [])
    }

    func test_excludedPaymentMethodIds_whenNoExclusions_shouldReturnEmpty() {
        let config: [PaymentMethodConfig] = [.card()]

        let ids = config.excludedPaymentMethodIds

        XCTAssertEqual(ids, [])
    }
}
