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
/// the `paymentMethodId` property encodes it back. If either drifts, the
/// backend starts receiving or sending identifiers that don't round-trip.
final class CardBrandTests: XCTestCase {
    // MARK: - Roundtrip (predefined brands)

    func test_roundtrip_forEveryPredefinedBrand_shouldReturnOriginalCase() {
        // Arrange -- walk all predefined brands exposed via `.defaults`
        for brand in MercadoPagoCheckout.CardBrand.defaults {
            // Act -- encode then decode
            let rebuilt = MercadoPagoCheckout.CardBrand(paymentMethodId: brand.paymentMethodId)

            // Assert
            XCTAssertEqual(rebuilt, brand, "brand: \(brand)")
        }
    }

    // MARK: - Payment method id casing (backend sends lowercase)

    func test_paymentMethodId_forUnionPay_shouldBeLowercase() {
        // Arrange -- `.unionPay` is camelCased in Swift but the backend id is lowercase
        XCTAssertEqual(MercadoPagoCheckout.CardBrand.unionPay.paymentMethodId, "unionpay")
    }

    func test_init_withLowercaseUnionPay_shouldReturnUnionPayCase() {
        XCTAssertEqual(MercadoPagoCheckout.CardBrand(paymentMethodId: "unionpay"), .unionPay)
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
        // Guardrail: deleting a brand from the defaults list would silently
        // stop showing that brand in seller-facing UI. Explicit check catches it.
        let identifiers = MercadoPagoCheckout.CardBrand.defaults.map(\.paymentMethodId)
        let expected: Set<String> = [
            "visa", "master", "amex", "elo", "hipercard", "diners",
            "discover", "jcb", "maestro", "unionpay", "cabal", "naranja"
        ]
        XCTAssertEqual(Set(identifiers), expected)
    }
}
