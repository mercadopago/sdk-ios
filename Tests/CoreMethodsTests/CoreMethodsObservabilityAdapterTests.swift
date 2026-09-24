@testable import CoreMethods
import CommonTests
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
        assertInput(
            APIClientError.invalidResponse(Data("non-empty".utf8)),
            type: .unknown,
            code: .exception
        )
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

    func testTrackedErrorCapturesOnceAndReusesTheReceiptIDForMelidata() async {
        let reporter = MockErrorObservability()
        let container = MockDependencyContainer(errorObservability: reporter)
        let repository = MockCoreMethodsRepository()
        let paymentMethodUseCase = PaymentMethodUseCase(repository: repository)
        let sut = CoreMethods(
            dependencies: container,
            generateTokenUseCase: GenerateCardTokenUseCase(
                dependencies: container,
                repository: repository,
                paymentMethodUseCase: paymentMethodUseCase
            ),
            identificationTypeUseCase: IdentificationTypesUseCase(repository: repository),
            installmentsUseCase: InstallmentsUseCase(repository: repository),
            paymentMethodUseCase: paymentMethodUseCase,
            issuerUseCase: IssuerUseCase(repository: repository)
        )
        await repository.setIdentificationTypesResult(
            .failure(APIClientError.apiError(.init(code: "500", message: "not retained")))
        )

        do {
            _ = try await sut.identificationTypes()
            XCTFail("Expected identificationTypes to throw")
        } catch {}
        await container.mockAnalytics.mock.waitForSend()

        let captures = await reporter.captures
        let observabilityEventIDs = await container.mockAnalytics.mock.getObservabilityEventIDs()
        XCTAssertEqual(captures.map(\.operation), [.identificationTypes])
        XCTAssertEqual(observabilityEventIDs, ["00000000-0000-4000-8000-000000000001"])
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
}

private struct TestError: Error {}
