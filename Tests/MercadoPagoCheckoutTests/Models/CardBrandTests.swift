//
//  CardBrandTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 23/04/26.
//

@testable import MercadoPagoCheckout
import XCTest

private typealias CardBrand = MercadoPagoCheckout<MPPaymentData.CardTransaction>.CardBrand

final class CardBrandTests: XCTestCase {
    private static let brandIdentifierTable: [(CardBrand, String)] = [
        (.visa, "visa"),
        (.master, "master"),
        (.amex, "amex"),
        (.elo, "elo"),
        (.hipercard, "hipercard"),
        (.diners, "diners"),
        (.discover, "discover"),
        (.jcb, "jcb"),
        (.maestro, "maestro"),
        (.unionPay, "unionpay"),
        (.cabal, "cabal"),
        (.naranja, "naranja")
    ]

    // MARK: - Encode (case → identifier)

    func test_paymentMethodId_shouldMatchExpectedIdentifier_forEveryBrand() {
        for (brand, expectedId) in Self.brandIdentifierTable {
            XCTAssertEqual(
                brand.paymentMethodId,
                expectedId,
                "encode mismatch for \(brand) — expected \"\(expectedId)\", got \"\(brand.paymentMethodId)\""
            )
        }
    }

    // MARK: - Decode (identifier → case)

    func test_init_shouldMapIdentifierToExpectedCase_forEveryBrand() {
        for (expectedBrand, id) in Self.brandIdentifierTable {
            XCTAssertEqual(
                CardBrand(paymentMethodId: id),
                expectedBrand,
                "decode mismatch for \"\(id)\" — expected \(expectedBrand)"
            )
        }
    }

    // MARK: - Custom fallback

    func test_init_withUnknownPaymentMethodId_shouldReturnCustomCase() {
        let brand = CardBrand(paymentMethodId: "sodexo_refeicao")
        XCTAssertEqual(brand, .custom("sodexo_refeicao"))
    }

    func test_paymentMethodId_forCustomCase_shouldReturnProvidedIdentifier() {
        XCTAssertEqual(CardBrand.custom("alelo").paymentMethodId, "alelo")
    }

    // MARK: - `.defaults` inventory

    func test_defaults_shouldContainExpectedBrands() {
        let identifiers = CardBrand.defaults.map(\.paymentMethodId)
        let expected = Set(Self.brandIdentifierTable.map(\.1))
        XCTAssertEqual(Set(identifiers), expected)
    }
}
