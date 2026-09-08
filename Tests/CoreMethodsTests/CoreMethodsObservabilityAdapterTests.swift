import CommonTests
@testable import CoreMethods
import Foundation
import MPCore
import XCTest

@MainActor
final class CoreMethodsObservabilityAdapterTests: XCTestCase {
    func testTypedErrorsUseOnlyClosedNeutralEvidence() {
        assertInput(CancellationError(), type: .requestCancellation, code: .cancelled)
        assertInput(CoreMethodsError.binIsEmpty, type: .validation)
        assertInput(CoreMethodsError.securityCodeInvalid, type: .validation)
        assertInput(CoreMethodsError.cardNumberInvalid, type: .validation)
        assertInput(CoreMethodsError.expirationDateInvalid, type: .validation)
        assertInput(CoreMethodsError.errorGettingEphemeralKey, type: .unknown, code: .unknownError)
        assertInput(APIClientError.invalidURL, type: .request, code: .invalidURL)
        assertInput(APIClientError.urlRequestIsEmpty, type: .request, code: .invalidURL)
        assertInput(APIClientError.invalidResponse(Data()), type: .request, responseState: .emptyBody)
        assertInput(APIClientError.decodingFailed(TestError()), type: .request, responseState: .decodeFailure)
        assertInput(
            APIClientError.apiError(APIErrorResponse(code: "400", message: "not retained")),
            type: .service
        )
        assertInput(TestError(), type: .unknown, code: .exception)
    }

    func testNestedRequestAndNetworkErrorsAreNormalizedWithoutText() {
        assertInput(
            APIClientError.networkError(URLError(.notConnectedToInternet)),
            type: .request,
            code: .offline
        )
        assertInput(
            APIClientError.requestFailed(URLError(.timedOut)),
            type: .request,
            code: .timeout
        )
        assertInput(
            APIClientError.networkError(URLError(.dnsLookupFailed)),
            type: .request,
            code: .dnsFailure
        )
        assertInput(
            APIClientError.requestFailed(URLError(.networkConnectionLost)),
            type: .request,
            code: .connectionLost
        )
        assertInput(
            APIClientError.networkError(URLError(.cancelled)),
            type: .requestCancellation,
            code: .cancelled
        )
    }

    func testReliableStatusesAreRetainedAsEvidence() {
        for status in [401, 403, 408, 422, 500, 504] {
            let input = CoreMethods.nativeErrorInput(from: APIClientError.statusCode(status))
            XCTAssertEqual(input, .init(type: .service, httpStatus: status))
        }

        let invalid = CoreMethods.nativeErrorInput(
            from: APIClientError.notExpectedHttpResponseCode(code: 700)
        )
        XCTAssertEqual(invalid.type, .service)
        XCTAssertNil(invalid.httpStatus)
    }

    func testTrackingPreservesOriginalErrorAndSharesReceiptIDForEveryOperation() async {
        let operations: [NativeErrorOperation] = [
            .identificationTypes, .installments, .paymentMethods, .issuers, .cardTokenization
        ]

        for operation in operations {
            let observability = MockErrorObservability(eventID: "shared-\(operation.rawValue)")
            let dependencies = MockDependencyContainer(errorObservability: observability)
            let sut = makeCoreMethods(dependencies: dependencies)

            do {
                let _: Int = try await sut.executeWithTracking(
                    operation: { throw TestFailure.original },
                    path: "/test/\(operation.rawValue)",
                    observabilityOperation: operation
                )
                XCTFail("Expected original error")
            } catch {
                XCTAssertEqual(error as? TestFailure, .original)
            }

            await dependencies.mockAnalytics.mock.waitForSend()
            XCTAssertEqual(observability.recordedErrors().first?.operation, operation)
            let eventIDs = await dependencies.mockAnalytics.mock.getObservabilityEventIDs()
            XCTAssertEqual(eventIDs.compactMap { $0 }, ["shared-\(operation.rawValue)"])
        }
    }

    private func assertInput(
        _ error: any Error,
        type: NativeErrorInputType,
        code: NativeErrorEvidenceCode? = nil,
        responseState: NativeErrorResponseState? = nil
    ) {
        let input = CoreMethods.nativeErrorInput(from: error)
        XCTAssertEqual(input.type, type)
        XCTAssertEqual(input.code, code)
        XCTAssertEqual(input.responseState, responseState)
        XCTAssertNil(input.requestCorrelationID)
    }

    private func makeCoreMethods(dependencies: MockDependencyContainer) -> CoreMethods {
        let repository = MockCoreMethodsRepository()
        let paymentMethodUseCase = PaymentMethodUseCase(repository: repository)
        return CoreMethods(
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
    }
}

private struct TestError: Error {}
private enum TestFailure: Error { case original }
