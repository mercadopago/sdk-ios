import CommonTests
@testable import CoreMethods
import MPCore
import XCTest

@MainActor
final class CoreMethodsObservabilityClassifierTests: XCTestCase {
    func testTypedAndNestedErrorsUseClosedMapping() {
        assertClassification(CancellationError(), code: .requestCancelled, diagnostic: .cancelled)
        assertClassification(CoreMethodsError.binIsEmpty, code: .inputValidationFailed, diagnostic: .validation)
        assertClassification(CoreMethodsError.errorGettingEphemeralKey, code: .operationFailed)
        assertClassification(APIClientError.invalidURL, code: .sdkConfigurationInvalid, diagnostic: .invalidURL)
        assertClassification(
            APIClientError.networkError(URLError(.notConnectedToInternet)),
            code: .connectionUnavailable,
            diagnostic: .offline
        )
        assertClassification(
            APIClientError.requestFailed(URLError(.timedOut)),
            code: .requestTimeout,
            diagnostic: .timeout
        )
        assertClassification(
            APIClientError.decodingFailed(TestError()),
            code: .responseContractInvalid,
            diagnostic: .decodeFailure
        )
    }

    func testReliableStatusesAreRetainedAndClassified() {
        let unauthorized = CoreMethods.classifiedNativeError(
            from: APIClientError.statusCode(401),
            operation: .identificationTypes
        )
        XCTAssertEqual(unauthorized.code, .sdkConfigurationInvalid)
        XCTAssertEqual(unauthorized.statusCode, 401)
        XCTAssertEqual(unauthorized.serviceTarget, .identificationTypes)
        XCTAssertEqual(unauthorized.diagnosticCode, .httpUnauthorized)

        let timeout = CoreMethods.classifiedNativeError(
            from: APIClientError.notExpectedHttpResponseCode(code: 504),
            operation: .cardTokenization
        )
        XCTAssertEqual(timeout.code, .requestTimeout)
        XCTAssertEqual(timeout.statusCode, 504)
        XCTAssertNil(timeout.serviceTarget)
    }

    func testTrackingPreservesOriginalErrorAndSharesReceiptID() async {
        let observability = MockErrorObservability(eventID: "shared-event-id")
        let dependencies = MockDependencyContainer(errorObservability: observability)
        let repository = MockCoreMethodsRepository()
        let paymentMethodUseCase = PaymentMethodUseCase(repository: repository)
        let sut = CoreMethods(
            dependencies: dependencies,
            generateTokenUseCase: GenerateCardTokenUseCase(
                dependencies: dependencies,
                repository: repository,
                paymentMethodUseCase: paymentMethodUseCase
            ),
            identificationTypeUseCase: IdentificationTypesUseCase(repository: repository),
            installmentsUseCase: InstallmentsUseCase(repository: repository),
            paymentMethodUseCase: paymentMethodUseCase,
            issuerUseCase: IssuerUseCase(repository: repository)
        )

        do {
            let _: Int = try await sut.executeWithTracking(
                operation: { throw TestFailure.original },
                path: "/test",
                observabilityOperation: .installments
            )
            XCTFail("Expected original error")
        } catch {
            XCTAssertEqual(error as? TestFailure, .original)
        }

        await dependencies.mockAnalytics.mock.waitForSend()
        XCTAssertEqual(observability.recordedErrors().first?.operation, .installments)
        let eventIDs = await dependencies.mockAnalytics.mock.getObservabilityEventIDs()
        XCTAssertEqual(eventIDs.compactMap { $0 }, ["shared-event-id"])
    }

    private func assertClassification(
        _ error: any Error,
        code: NativeErrorCode,
        diagnostic: NativeErrorDiagnosticCode? = nil
    ) {
        let result = CoreMethods.classifiedNativeError(from: error, operation: .installments)
        XCTAssertEqual(result.code, code)
        XCTAssertEqual(result.diagnosticCode, diagnostic)
    }
}

private struct TestError: Error {}
private enum TestFailure: Error { case original }
