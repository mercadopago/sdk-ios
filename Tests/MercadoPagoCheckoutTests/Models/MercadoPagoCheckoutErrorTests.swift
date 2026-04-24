//
//  MercadoPagoCheckoutErrorTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 23/04/26.
//

@testable import MercadoPagoCheckout
import XCTest

/// Tests the public surface of `MercadoPagoCheckoutError` that consumers depend on:
/// stable error codes, stable location raw values, the custom Equatable scope,
/// and the CustomNSError bridge. Conformances synthesized by the compiler
/// (RawRepresentable, Hashable, basic init) are intentionally not tested —
/// they are a Swift guarantee, not ours.
final class MercadoPagoCheckoutErrorTests: XCTestCase {
    // MARK: - Code — public contract (error codes are an SDK-public integer API)

    func test_code_networkConnectionFailed_shouldBeMinus1009() {
        XCTAssertEqual(MercadoPagoCheckoutError.Code.networkConnectionFailed.rawValue, -1009)
    }

    func test_code_networkTimeout_shouldBeMinus1001() {
        XCTAssertEqual(MercadoPagoCheckoutError.Code.networkTimeout.rawValue, -1001)
    }

    func test_code_serviceError_shouldBe2000() {
        XCTAssertEqual(MercadoPagoCheckoutError.Code.serviceError.rawValue, 2000)
    }

    func test_code_unknown_shouldBe999() {
        XCTAssertEqual(MercadoPagoCheckoutError.Code.unknown.rawValue, 999)
    }

    func test_code_integrationError_shouldBe3000() {
        XCTAssertEqual(MercadoPagoCheckoutError.Code.integrationError.rawValue, 3000)
    }

    // MARK: - LocationDescription — raw values are exposed publicly via `locationDescription`

    func test_locationDescription_rawValuesShouldBeStable() {
        // Consumers inspect `error.locationDescription` as a string. Any rename
        // of the underlying enum case silently breaks that API.
        let expected: [MercadoPagoCheckoutError.LocationDescription: String] = [
            .tokenization: "tokenization",
            .identification: "identification",
            .paymentMethods: "paymentMethods",
            .installments: "installments",
            .issuer: "issuer",
            .initialization: "initialization"
        ]

        for (location, rawValue) in expected {
            XCTAssertEqual(location.rawValue, rawValue)
        }
    }

    // MARK: - CustomNSError bridge

    func test_errorDomain_shouldBeMercadoPagoSDK() {
        XCTAssertEqual(MercadoPagoCheckoutError.errorDomain, "MercadoPagoSDK")
    }

    func test_errorCode_shouldDelegateToCodeRawValue() {
        // Arrange -- NSError integration: `errorCode` must match `code.rawValue`
        let error = MercadoPagoCheckoutError(
            code: .networkTimeout,
            localizedDescription: "x",
            location: .issuer
        )

        // Assert
        XCTAssertEqual(error.errorCode, -1001)
    }

    // MARK: - debugDescription format

    func test_debugDescription_shouldIncludeCodeLocationAndDescription() {
        // Arrange / Act
        let error = MercadoPagoCheckoutError(
            code: .serviceError,
            localizedDescription: "broken",
            location: .tokenization
        )

        // Assert -- substring checks; full format is intentionally not pinned
        let debug = error.debugDescription
        XCTAssertTrue(debug.contains("2000"))
        XCTAssertTrue(debug.contains("tokenization"))
        XCTAssertTrue(debug.contains("broken"))
    }

    // MARK: - Equatable — custom `==` intentionally ignores userInfo and description

    func test_equatable_whenSameCodeAndLocation_shouldBeEqual_evenIfUserInfoDiffers() {
        // Arrange -- this is the load-bearing property; scoping equality to
        // (code, location) is what makes the error usable in Sets/Dictionaries
        // for "have we seen this kind of failure yet?" checks.
        let a = MercadoPagoCheckoutError(
            code: .unknown,
            localizedDescription: "one",
            userInfo: ["k": "v1"],
            location: .issuer
        )
        let b = MercadoPagoCheckoutError(
            code: .unknown,
            localizedDescription: "two",
            userInfo: ["k": "v2"],
            location: .issuer
        )

        // Assert
        XCTAssertEqual(a, b)
    }

    func test_equatable_whenDifferentCodes_shouldNotBeEqual() {
        let a = MercadoPagoCheckoutError(code: .unknown, localizedDescription: "x", location: .issuer)
        let b = MercadoPagoCheckoutError(code: .serviceError, localizedDescription: "x", location: .issuer)
        XCTAssertNotEqual(a, b)
    }

    func test_equatable_whenDifferentLocations_shouldNotBeEqual() {
        let a = MercadoPagoCheckoutError(code: .unknown, localizedDescription: "x", location: .issuer)
        let b = MercadoPagoCheckoutError(code: .unknown, localizedDescription: "x", location: .tokenization)
        XCTAssertNotEqual(a, b)
    }
}
