//
//  MercadoPagoCheckoutPayerTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 24/04/26.
//

@testable import MercadoPagoCheckout
import XCTest

private typealias Payer = MercadoPagoCheckout<MPPaymentData.CardTransaction>.Payer

/// Thin struct, but it's public API — verify the public init stores the email
/// so a future Codable / stored-property addition doesn't silently break
/// consumers that depend on the single-field shape.
final class MercadoPagoCheckoutPayerTests: XCTestCase {
    func test_init_shouldStoreEmail() {
        let payer = Payer(email: "maria@example.com")
        XCTAssertEqual(payer.email, "maria@example.com")
    }

    func test_init_shouldAcceptEmptyString() {
        // Arrange -- constructor does not validate; emptiness is a valid state
        // for "email was intentionally cleared."
        let payer = Payer(email: "")
        XCTAssertEqual(payer.email, "")
    }
}
