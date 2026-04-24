//
//  CardBrandTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 23/04/26.
//

@testable import MercadoPagoCheckout
import XCTest

/// The `CardBrand` type has two mappings that must stay in sync:
/// `init(paymentMethodId:)` decodes the backend identifier into a case, and
/// the `paymentMethodId` property encodes it back. Both directions are
/// anchored to explicit string literals below — testing only the roundtrip
/// would miss a symmetric drift (both sides renamed to the same wrong id),
/// which would still round-trip cleanly while sending the wrong value to
/// the backend.
final class CardBrandTests: XCTestCase {
    /// Canonical mapping between the Swift case and the backend identifier.
    /// Drive both directions from this table so a rename on one side fails
    /// loudly without needing a matching rename on the other.
    private static let brandIdentifierTable: [(MercadoPagoCheckout.CardBrand, String)] = [
        (.visa, "visa"),
        (.master, "master"),
        (.amex, "amex"),
        (.elo, "elo"),
        (.hipercard, "hipercard"),
        (.diners, "diners"),
        (.discover, "discover"),
        (.jcb, "jcb"),
        (.maestro, "maestro"),
        // .unionPay is camelCased in Swift but lowercase in the backend
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
                MercadoPagoCheckout.CardBrand(paymentMethodId: id),
                expectedBrand,
                "decode mismatch for \"\(id)\" — expected \(expectedBrand)"
            )
        }
    }

    // MARK: - Custom fallback

    func test_init_withUnknownPaymentMethodId_shouldReturnCustomCase() {
        // Arrange / Act
        let brand = MercadoPagoCheckout.CardBrand(paymentMethodId: "sodexo_refeicao")

        // Assert
        XCTAssertEqual(brand, .custom("sodexo_refeicao"))
    }

    func test_paymentMethodId_forCustomCase_shouldReturnProvidedIdentifier() {
        XCTAssertEqual(MercadoPagoCheckout.CardBrand.custom("alelo").paymentMethodId, "alelo")
    }

    // MARK: - `.defaults` inventory

    func test_defaults_shouldContainExpectedBrands() {
        // Guardrail: deleting a brand from `.defaults` would silently stop
        // showing that brand in seller-facing UI. Explicit check catches it.
        let identifiers = MercadoPagoCheckout.CardBrand.defaults.map(\.paymentMethodId)
        let expected = Set(Self.brandIdentifierTable.map(\.1))
        XCTAssertEqual(Set(identifiers), expected)
    }
}
