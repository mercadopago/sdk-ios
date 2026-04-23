//
//  MercadoPagoCheckoutErrorTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 23/04/26.
//

@testable import MercadoPagoCheckout
import XCTest

final class MercadoPagoCheckoutErrorTests: XCTestCase {
    // MARK: - Code — RawRepresentable

    func test_code_initWithRawValue_shouldStoreValue() {
        let code = MercadoPagoCheckoutError.Code(rawValue: 42)
        XCTAssertEqual(code.rawValue, 42)
    }

    func test_code_shouldBeEquatable_whenSameRawValue() {
        let a = MercadoPagoCheckoutError.Code(rawValue: 7)
        let b = MercadoPagoCheckoutError.Code(rawValue: 7)
        XCTAssertEqual(a, b)
    }

    func test_code_shouldBeNotEqual_whenDifferentRawValue() {
        let a = MercadoPagoCheckoutError.Code(rawValue: 7)
        let b = MercadoPagoCheckoutError.Code(rawValue: 8)
        XCTAssertNotEqual(a, b)
    }

    func test_code_shouldBeHashable() {
        // Arrange
        let a = MercadoPagoCheckoutError.Code(rawValue: 7)
        let b = MercadoPagoCheckoutError.Code(rawValue: 7)
        var set: Set<MercadoPagoCheckoutError.Code> = []

        // Act
        set.insert(a)
        set.insert(b)

        // Assert
        XCTAssertEqual(set.count, 1)
    }

    // MARK: - Code — predefined values

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

    // MARK: - Public static accessors (MercadoPagoCheckoutError+Error.swift)

    func test_publicStatic_networkConnectionFailed_shouldMatchCode() {
        XCTAssertEqual(MercadoPagoCheckoutError.networkConnectionFailed, .networkConnectionFailed)
    }

    func test_publicStatic_networkTimeout_shouldMatchCode() {
        XCTAssertEqual(MercadoPagoCheckoutError.networkTimeout, .networkTimeout)
    }

    func test_publicStatic_service_shouldMatchServiceError() {
        // Arrange -- public accessor is named `service` but maps to `.serviceError`
        XCTAssertEqual(MercadoPagoCheckoutError.service, .serviceError)
    }

    func test_publicStatic_integrationError_shouldMatchCode() {
        XCTAssertEqual(MercadoPagoCheckoutError.integrationError, .integrationError)
    }

    func test_publicStatic_unknown_shouldMatchCode() {
        XCTAssertEqual(MercadoPagoCheckoutError.unknown, .unknown)
    }

    // MARK: - LocationDescription

    func test_locationDescription_shouldHaveAllSixCases() {
        let allCases = MercadoPagoCheckoutError.LocationDescription.allCases
        XCTAssertEqual(allCases.count, 6)
    }

    func test_locationDescription_rawValuesShouldBeStable() {
        // Arrange -- raw values are part of the public error surface; regressions here break
        // consumers that inspect `locationDescription` string.
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

    // MARK: - Error struct — init + stored fields

    func test_init_shouldStoreAllFields() {
        // Arrange
        let userInfo: [String: Any] = ["foo": "bar", "n": 42]

        // Act
        let error = MercadoPagoCheckoutError(
            code: .serviceError,
            localizedDescription: "boom",
            userInfo: userInfo,
            location: .tokenization
        )

        // Assert
        XCTAssertEqual(error.code, .serviceError)
        XCTAssertEqual(error.errorDescription, "boom")
        XCTAssertEqual(error.locationDescription, "tokenization")
        XCTAssertEqual(error.errorUserInfo["foo"] as? String, "bar")
        XCTAssertEqual(error.errorUserInfo["n"] as? Int, 42)
    }

    func test_init_defaultUserInfo_shouldBeEmpty() {
        // Arrange / Act
        let error = MercadoPagoCheckoutError(
            code: .unknown,
            localizedDescription: "x",
            location: .installments
        )

        // Assert
        XCTAssertTrue(error.errorUserInfo.isEmpty)
    }

    // MARK: - CustomNSError

    func test_errorDomain_shouldBeMercadoPagoSDK() {
        XCTAssertEqual(MercadoPagoCheckoutError.errorDomain, "MercadoPagoSDK")
    }

    func test_errorCode_shouldMatchCodeRawValue() {
        // Arrange / Act
        let error = MercadoPagoCheckoutError(
            code: .networkTimeout,
            localizedDescription: "x",
            location: .issuer
        )

        // Assert
        XCTAssertEqual(error.errorCode, -1001)
    }

    // MARK: - CustomDebugStringConvertible

    func test_debugDescription_shouldIncludeCodeLocationAndDescription() {
        // Arrange / Act
        let error = MercadoPagoCheckoutError(
            code: .serviceError,
            localizedDescription: "broken",
            location: .tokenization
        )

        // Assert -- soft assertions on substrings; we don't pin the full format
        let debug = error.debugDescription
        XCTAssertTrue(debug.contains("2000"), "should include code rawValue")
        XCTAssertTrue(debug.contains("tokenization"), "should include location")
        XCTAssertTrue(debug.contains("broken"), "should include description")
    }

    // MARK: - Equatable

    func test_equatable_whenSameCodeAndLocation_shouldBeEqual() {
        let a = MercadoPagoCheckoutError(code: .unknown, localizedDescription: "a", location: .issuer)
        let b = MercadoPagoCheckoutError(code: .unknown, localizedDescription: "b", location: .issuer)
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

    func test_equatable_shouldIgnoreUserInfoAndDescription() {
        // Arrange -- equality is intentionally scoped to (code, location)
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
}
