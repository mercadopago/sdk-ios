import CoreMethods
import Foundation
@testable import MercadoPagoCheckout
import MPCore
import XCTest

final class ObservedCheckoutErrorFactoryTests: XCTestCase {
    func testTypedNetworkEvidenceRetainsTheOriginalPublicError() {
        let observed = ObservedCheckoutErrorFactory.make(
            from: APIClientError.networkError(URLError(.notConnectedToInternet)),
            location: .tokenization
        )

        XCTAssertEqual(observed.publicError.code, .networkConnectionFailed)
        XCTAssertEqual(observed.publicError.locationDescription, "tokenization")
        XCTAssertEqual(observed.input, .init(type: .request, code: .offline))
    }

    func testReliableHTTPStatusIsReducedToValidatedEvidence() {
        let observed = ObservedCheckoutErrorFactory.make(
            from: APIClientError.statusCode(504),
            location: .orderProcess
        )

        XCTAssertEqual(observed.publicError.errorUserInfo["status_code"] as? Int, 504)
        XCTAssertEqual(observed.input, .init(type: .service, httpStatus: 504))

        let invalid = ObservedCheckoutErrorFactory.make(
            from: APIClientError.statusCode(700),
            location: .orderProcess
        )
        XCTAssertNil(invalid.input.httpStatus)
    }

    func testInitializationIntegrationConversionPreservesPublicBehavior() {
        let response = APIErrorResponse(
            code: "bad_request",
            message: "legacy message",
            errorCode: "UNSUPPORTED_SITE"
        )
        let observed = ObservedCheckoutErrorFactory.make(
            from: APIClientError.apiError(response),
            location: .initialization,
            recognizeIntegrationError: true
        )

        XCTAssertEqual(observed.publicError.code, .integrationError)
        XCTAssertEqual(observed.publicError.errorDescription, "legacy message")
        XCTAssertEqual(observed.input, .init(type: .validation, code: .integration))
    }

    func testResponseFailuresRetainOnlyClosedState() {
        let empty = ObservedCheckoutErrorFactory.make(
            from: APIClientError.invalidResponse(Data()),
            location: .initialization
        )
        let nonEmpty = ObservedCheckoutErrorFactory.make(
            from: APIClientError.invalidResponse(Data("private body".utf8)),
            location: .initialization
        )
        let decoded = ObservedCheckoutErrorFactory.make(
            from: APIClientError.decodingFailed(TestFailure()),
            location: .orderProcess
        )

        XCTAssertEqual(empty.input, .init(type: .request, responseState: .emptyBody))
        XCTAssertEqual(nonEmpty.input, .init(type: .unknown, code: .exception))
        XCTAssertEqual(decoded.input, .init(type: .request, responseState: .decodeFailure))
        XCTAssertEqual(Set(Mirror(reflecting: empty).children.compactMap(\.label)), ["publicError", "input"])
    }

    func testExistingPublicErrorIdentityIsPreserved() {
        let original = MercadoPagoCheckoutError(
            code: .serviceError,
            localizedDescription: "unchanged",
            userInfo: ["status_code": 403],
            location: .orderProcess
        )
        let observed = ObservedCheckoutErrorFactory.make(from: original, location: .initialization)

        XCTAssertEqual(observed.publicError.errorDescription, original.errorDescription)
        XCTAssertEqual(observed.publicError.locationDescription, original.locationDescription)
        XCTAssertEqual(observed.input, .init(type: .service, httpStatus: 403))
    }
}

private struct TestFailure: Error {}
