//
//  MercadoPagoCheckoutErrorNetworkTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 23/04/26.
//

@testable import MercadoPagoCheckout
@testable import MPCore
import XCTest

final class MercadoPagoCheckoutErrorNetworkTests: XCTestCase {
    // MARK: - networkError → networkConnectionFailed

    func test_init_whenNotConnectedToInternet_shouldReturnNetworkConnectionFailed() {
        self.assertConnectionFailed(urlErrorCode: .notConnectedToInternet)
    }

    func test_init_whenCannotFindHost_shouldReturnNetworkConnectionFailed() {
        self.assertConnectionFailed(urlErrorCode: .cannotFindHost)
    }

    func test_init_whenCannotConnectToHost_shouldReturnNetworkConnectionFailed() {
        self.assertConnectionFailed(urlErrorCode: .cannotConnectToHost)
    }

    func test_init_whenDNSLookupFailed_shouldReturnNetworkConnectionFailed() {
        self.assertConnectionFailed(urlErrorCode: .dnsLookupFailed)
    }

    func test_init_whenInternationalRoamingOff_shouldReturnNetworkConnectionFailed() {
        self.assertConnectionFailed(urlErrorCode: .internationalRoamingOff)
    }

    func test_init_whenDataNotAllowed_shouldReturnNetworkConnectionFailed() {
        self.assertConnectionFailed(urlErrorCode: .dataNotAllowed)
    }

    func test_init_whenCallIsActive_shouldReturnNetworkConnectionFailed() {
        self.assertConnectionFailed(urlErrorCode: .callIsActive)
    }

    func test_init_whenNetworkConnectionLost_shouldReturnNetworkConnectionFailed() {
        self.assertConnectionFailed(urlErrorCode: .networkConnectionLost)
    }

    // MARK: - networkError → networkTimeout

    func test_init_whenTimedOut_shouldReturnNetworkTimeout() {
        // Arrange
        let apiError = APIClientError.networkError(URLError(.timedOut))

        // Act
        let error = MercadoPagoCheckoutError(from: apiError, location: .paymentMethods)

        // Assert
        XCTAssertEqual(error.code, .networkTimeout)
        XCTAssertEqual(error.errorDescription, "The request timed out.")
        XCTAssertEqual(error.locationDescription, "paymentMethods")
    }

    // MARK: - networkError → unknown fallback

    func test_init_whenOtherURLError_shouldReturnUnknownWithUnderlyingDescription() {
        // Arrange — any URLError not listed in the switch (e.g. badURL) should fall through
        let urlError = URLError(.badURL)
        let apiError = APIClientError.networkError(urlError)

        // Act
        let error = MercadoPagoCheckoutError(from: apiError, location: .tokenization)

        // Assert
        XCTAssertEqual(error.code, .unknown)
        XCTAssertEqual(error.errorDescription, urlError.localizedDescription)
        XCTAssertEqual(error.locationDescription, "tokenization")
    }

    func test_init_whenNetworkErrorWithNonURLError_shouldReturnUnknown() {
        // Arrange — wrap a non-URLError underlying error; cast to URLError fails, default path runs
        struct GenericError: Error, LocalizedError {
            var errorDescription: String? { "boom" }
        }
        let apiError = APIClientError.networkError(GenericError())

        // Act
        let error = MercadoPagoCheckoutError(from: apiError, location: .initialization)

        // Assert
        XCTAssertEqual(error.code, .unknown)
        XCTAssertEqual(error.errorDescription, "boom")
    }

    // MARK: - apiError

    func test_init_whenAPIError_shouldReturnServiceErrorWithCodeAndMessage() {
        // Arrange
        let apiResponse = APIErrorResponse(code: "invalid_card", message: "Card is invalid")
        let apiError = APIClientError.apiError(apiResponse)

        // Act
        let error = MercadoPagoCheckoutError(from: apiError, location: .tokenization)

        // Assert
        XCTAssertEqual(error.code, .serviceError)
        XCTAssertEqual(
            error.errorDescription,
            "An error occurred. Check the error_code for more details."
        )
        XCTAssertEqual(error.errorUserInfo["error_code"] as? String, "invalid_card")
        XCTAssertEqual(error.errorUserInfo["message"] as? String, "Card is invalid")
        XCTAssertEqual(error.locationDescription, "tokenization")
    }

    // MARK: - statusCode

    func test_init_whenStatusCode_shouldReturnServiceErrorWithStatusCode() {
        // Arrange
        let apiError = APIClientError.statusCode(500)

        // Act
        let error = MercadoPagoCheckoutError(from: apiError, location: .installments)

        // Assert
        XCTAssertEqual(error.code, .serviceError)
        XCTAssertEqual(
            error.errorDescription,
            "An error occurred. Check the status_code for more details."
        )
        XCTAssertEqual(error.errorUserInfo["status_code"] as? Int, 500)
        XCTAssertEqual(error.locationDescription, "installments")
    }

    // MARK: - invalidURL

    func test_init_whenInvalidURL_shouldReturnUnknown() {
        // Arrange
        let apiError = APIClientError.invalidURL

        // Act
        let error = MercadoPagoCheckoutError(from: apiError, location: .identification)

        // Assert
        XCTAssertEqual(error.code, .unknown)
        XCTAssertEqual(error.errorDescription, "Invalid URL.")
    }

    // MARK: - invalidResponse

    func test_init_whenInvalidResponse_shouldReturnUnknownAndCarryPayloadInUserInfo() {
        // Arrange
        let payload = Data("bogus".utf8)
        let apiError = APIClientError.invalidResponse(payload)

        // Act
        let error = MercadoPagoCheckoutError(from: apiError, location: .paymentMethods)

        // Assert
        XCTAssertEqual(error.code, .unknown)
        XCTAssertEqual(error.errorDescription, "invalid_response")
        XCTAssertEqual(error.errorUserInfo["data"] as? Data, payload)
    }

    // MARK: - decodingFailed

    func test_init_whenDecodingFailed_shouldReturnUnknownWithUnderlyingDescription() {
        // Arrange
        struct DecodeError: Error, LocalizedError {
            var errorDescription: String? { "malformed json" }
        }
        let apiError = APIClientError.decodingFailed(DecodeError())

        // Act
        let error = MercadoPagoCheckoutError(from: apiError, location: .paymentMethods)

        // Assert
        XCTAssertEqual(error.code, .unknown)
        XCTAssertEqual(error.errorDescription, "malformed json")
    }

    // MARK: - requestFailed

    func test_init_whenRequestFailed_shouldReturnUnknownWithUnderlyingDescription() {
        // Arrange
        struct ReqError: Error, LocalizedError {
            var errorDescription: String? { "request blew up" }
        }
        let apiError = APIClientError.requestFailed(ReqError())

        // Act
        let error = MercadoPagoCheckoutError(from: apiError, location: .installments)

        // Assert
        XCTAssertEqual(error.code, .unknown)
        XCTAssertEqual(error.errorDescription, "request blew up")
    }

    // MARK: - notExpectedHttpResponseCode

    func test_init_whenNotExpectedHttpResponseCode_shouldReturnUnknownWithInlineCode() {
        // Arrange
        let apiError = APIClientError.notExpectedHttpResponseCode(code: 418)

        // Act
        let error = MercadoPagoCheckoutError(from: apiError, location: .tokenization)

        // Assert
        XCTAssertEqual(error.code, .unknown)
        XCTAssertEqual(error.errorDescription, "Not expected HTTP response code: 418")
    }

    // MARK: - urlRequestIsEmpty

    func test_init_whenURLRequestIsEmpty_shouldReturnUnknown() {
        // Arrange
        let apiError = APIClientError.urlRequestIsEmpty

        // Act
        let error = MercadoPagoCheckoutError(from: apiError, location: .identification)

        // Assert
        XCTAssertEqual(error.code, .unknown)
        XCTAssertEqual(error.errorDescription, "URL request is empty")
    }

    // MARK: - Location preservation

    func test_init_shouldPreserveEveryLocation() {
        // Arrange / Act / Assert -- same apiError, different locations
        let apiError = APIClientError.invalidURL

        for location in MercadoPagoCheckoutError.LocationDescription.allCases {
            let error = MercadoPagoCheckoutError(from: apiError, location: location)
            XCTAssertEqual(error.locationDescription, location.rawValue, "location: \(location)")
        }
    }

    // MARK: - isPaymentMethodNotFound

    func test_isPaymentMethodNotFound_whenErrorCodeIsNotFound_shouldReturnTrue() {
        // Arrange
        let apiResponse = APIErrorResponse(code: "not_found", message: "anything")
        let error = MercadoPagoCheckoutError(from: .apiError(apiResponse), location: .paymentMethods)

        // Assert
        XCTAssertTrue(error.isPaymentMethodNotFound)
    }

    func test_isPaymentMethodNotFound_whenMessageMatchesExactString_shouldReturnTrue() {
        // Arrange
        let apiResponse = APIErrorResponse(code: "something_else", message: "Payment methods not found")
        let error = MercadoPagoCheckoutError(from: .apiError(apiResponse), location: .paymentMethods)

        // Assert
        XCTAssertTrue(error.isPaymentMethodNotFound)
    }

    func test_isPaymentMethodNotFound_whenNeitherMatches_shouldReturnFalse() {
        // Arrange
        let apiResponse = APIErrorResponse(code: "validation_error", message: "Some other message")
        let error = MercadoPagoCheckoutError(from: .apiError(apiResponse), location: .paymentMethods)

        // Assert
        XCTAssertFalse(error.isPaymentMethodNotFound)
    }

    func test_isPaymentMethodNotFound_whenErrorHasNoUserInfo_shouldReturnFalse() {
        // Arrange -- any error without error_code/message in userInfo
        let error = MercadoPagoCheckoutError(from: .invalidURL, location: .paymentMethods)

        // Assert
        XCTAssertFalse(error.isPaymentMethodNotFound)
    }

    // MARK: - Helpers

    private func assertConnectionFailed(
        urlErrorCode: URLError.Code,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        // Arrange
        let apiError = APIClientError.networkError(URLError(urlErrorCode))

        // Act
        let error = MercadoPagoCheckoutError(from: apiError, location: .paymentMethods)

        // Assert
        XCTAssertEqual(error.code, .networkConnectionFailed, file: file, line: line)
        XCTAssertEqual(error.errorDescription, "No internet connection.", file: file, line: line)
    }
}
