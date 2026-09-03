@testable import MercadoPagoCheckout
import MPCore
import XCTest

final class MercadoPagoCheckoutErrorObservabilityTests: XCTestCase {
    func testCancellationAndNetworkMappings() {
        let cancellation = error(code: .unknown)
            .classifiedNativeError(operation: .cardFormCancellation, explicitCancellation: true)
        XCTAssertEqual(cancellation.code, .userCancelled)
        XCTAssertFalse(cancellation.code.isCritical)

        let offline = error(code: .networkConnectionFailed)
            .classifiedNativeError(operation: .cardFormSubmission)
        XCTAssertEqual(offline.code, .connectionUnavailable)
        XCTAssertNil(offline.serviceTarget)
    }

    func testStatusAndExactDecodeMarkersAreBounded() {
        let timeout = error(code: .serviceError, userInfo: ["status_code": 504, "body": "forbidden"])
            .classifiedNativeError(operation: .orderSubmission)
        XCTAssertEqual(timeout.code, .requestTimeout)
        XCTAssertEqual(timeout.statusCode, 504)
        XCTAssertEqual(timeout.serviceTarget, .orders)

        let invalidStatus = error(code: .serviceError, userInfo: ["status_code": "504"])
            .classifiedNativeError(operation: .cardFormInitialization)
        XCTAssertEqual(invalidStatus.code, .upstreamRejected)
        XCTAssertNil(invalidStatus.statusCode)

        let decode = error(code: .unknown, description: "Decoding failed: missing key 'id'.")
            .classifiedNativeError(operation: .cardFormInitialization)
        XCTAssertEqual(decode.code, .responseContractInvalid)
        XCTAssertEqual(decode.serviceTarget, .checkoutInitialization)

        let arbitrary = error(code: .unknown, description: "Decoding failed somewhere")
            .classifiedNativeError(operation: .cardFormSubmission)
        XCTAssertEqual(arbitrary.code, .operationFailed)
    }

    func testIntegrationPrecedesValidationServiceCode() {
        let response = APIErrorResponse(
            code: "ignored",
            message: "must not be copied",
            errorCode: CheckoutAPIErrorCode.identificationTypeUnavailable.rawValue
        )
        let checkoutError = MercadoPagoCheckoutError(
            code: .serviceError,
            localizedDescription: "ignored",
            location: .initialization,
            serviceError: response
        )
        XCTAssertEqual(
            checkoutError.classifiedNativeError(operation: .cardFormInitialization).code,
            .sdkConfigurationInvalid
        )
    }

    func testValidationAndFallbackMappings() {
        for code in [
            CheckoutAPIErrorCode.emptyPaymentMethods,
            .paymentMethodUnavailable,
            .installmentsUnavailable
        ] {
            let response = APIErrorResponse(code: "ignored", message: "ignored", errorCode: code.rawValue)
            let checkoutError = MercadoPagoCheckoutError(
                code: .serviceError,
                localizedDescription: "ignored",
                location: .initialization,
                serviceError: response
            )
            XCTAssertEqual(
                checkoutError.classifiedNativeError(operation: .cardFormInitialization).code,
                .inputValidationFailed
            )
        }

        XCTAssertEqual(
            error(code: .integrationError).classifiedNativeError(operation: .cardFormSubmission).code,
            .sdkConfigurationInvalid
        )
        XCTAssertEqual(
            error(code: .unknown).classifiedNativeError(operation: .cardFormSubmission).code,
            .operationFailed
        )
    }

    func testServiceStatusMappings() {
        let cases: [(Int, NativeErrorCode, NativeErrorDiagnosticCode?)] = [
            (408, .requestTimeout, .timeout),
            (504, .requestTimeout, .timeout),
            (401, .sdkConfigurationInvalid, .httpUnauthorized),
            (403, .sdkConfigurationInvalid, .httpForbidden),
            (422, .upstreamRejected, nil),
            (500, .upstreamRejected, nil)
        ]

        for (status, code, diagnostic) in cases {
            let classification = error(code: .serviceError, userInfo: ["status_code": status])
                .classifiedNativeError(operation: .orderSubmission)
            XCTAssertEqual(classification.code, code)
            XCTAssertEqual(classification.statusCode, status)
            XCTAssertEqual(classification.diagnosticCode, diagnostic)
        }
    }

    func testFiveTrackedOperationsHaveOnlyProvenServiceTargets() {
        let checkoutError = error(code: .unknown)
        let cases: [(NativeErrorOperation, NativeErrorServiceTarget?)] = [
            (.cardFormInitialization, .checkoutInitialization),
            (.cardFormSubmission, nil),
            (.orderSubmission, .orders),
            (.cardFormCancellation, nil),
            (.installmentsCancellation, nil)
        ]

        for (operation, target) in cases {
            XCTAssertEqual(checkoutError.classifiedNativeError(operation: operation).serviceTarget, target)
        }
    }

    private func error(
        code: MercadoPagoCheckoutError.Code,
        description: String = "error",
        userInfo: [String: Any] = [:]
    ) -> MercadoPagoCheckoutError {
        MercadoPagoCheckoutError(
            code: code,
            localizedDescription: description,
            userInfo: userInfo,
            location: .tokenization
        )
    }
}
