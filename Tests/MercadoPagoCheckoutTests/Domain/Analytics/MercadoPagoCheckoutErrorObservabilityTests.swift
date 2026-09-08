import MPCore
@testable import MercadoPagoCheckout
import XCTest

final class MercadoPagoCheckoutErrorObservabilityTests: XCTestCase {
    func testFiveTrackedOperationsUseCentralClassifierOutputs() {
        let cases: [
            (
                operation: NativeErrorOperation,
                input: NativeErrorInput,
                code: NativeErrorCode,
                target: NativeErrorServiceTarget?
            )
        ] = [
            (.cardFormInitialization, .init(type: .validation, code: .integration),
             .sdkConfigurationInvalid, .checkoutInitialization),
            (.cardFormSubmission, .init(type: .request, code: .offline),
             .connectionUnavailable, nil),
            (.orderSubmission, .init(type: .service, httpStatus: 504),
             .requestTimeout, .orders),
            (.cardFormCancellation, .checkoutUserCancellation, .userCancelled, nil),
            (.installmentsCancellation, .checkoutUserCancellation, .userCancelled, nil)
        ]

        for testCase in cases {
            let classified = NativeErrorClassifier.classify(
                operation: testCase.operation,
                input: testCase.input
            )
            XCTAssertEqual(classified.code, testCase.code)
            XCTAssertEqual(classified.serviceTarget, testCase.target)
        }
    }

    func testExplicitCancellationUsesStandaloneEvidenceWithoutPublicError() {
        let input = NativeErrorInput.checkoutUserCancellation
        XCTAssertEqual(input.type, .userCancellation)
        XCTAssertNil(input.code)
        XCTAssertNil(input.httpStatus)
        XCTAssertNil(input.requestCorrelationID)
    }

    func testFactoryEvidencePreservesClassifierPrecedence() {
        let publicError = MercadoPagoCheckoutError(
            code: .serviceError,
            localizedDescription: "legacy only",
            userInfo: ["status_code": 403, "body": "never retained"],
            location: .orderProcess
        )
        let observed = ObservedCheckoutErrorFactory.make(
            from: publicError,
            location: .orderProcess
        )
        let classified = NativeErrorClassifier.classify(
            operation: .orderSubmission,
            input: observed.input
        )

        XCTAssertEqual(classified.code, .sdkConfigurationInvalid)
        XCTAssertEqual(classified.statusCode, 403)
        XCTAssertEqual(classified.diagnosticCode, .httpForbidden)
    }
}
