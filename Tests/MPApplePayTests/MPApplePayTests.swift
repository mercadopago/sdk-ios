
import XCTest
import PassKit
import CommonTests
@testable import MPApplePay

final class MPApplePayTests: XCTestCase {

    // MARK: - Typealias
    private typealias SUT = (
        sut: MPApplePay,
        useCase: ApplePayUseCaseMock,
        dependencies: MockDependencyContainer
    )

    // MARK: - Stubs
    private enum ApplePayTokenStub {
        static let validToken = MPApplePayToken(id: "token_id", bin: "123456")
    }

    private enum APIErrorStub {
        static let genericError = NSError(domain: "test_domain", code: 1, userInfo: nil)
    }

    // MARK: - SUT Factory
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
        let useCaseMock = ApplePayUseCaseMock()
        let dependencies = MockDependencyContainer()
        let sut = MPApplePay(dependencies: dependencies, useCaseMock)
        return (sut: sut, useCase: useCaseMock, dependencies: dependencies)
    }

    // MARK: - Tests
    func test_createToken_whenUseCaseSucceeds_shouldReturnToken() async throws {
        // Arrange
        let (sut, useCaseMock, dependencies) = makeSUT()
        await useCaseMock.setCreateToken(result: .success(ApplePayTokenStub.validToken))
        let paymentToken = PKPaymentToken()

        // Expectation for analytics send
        let sendExpectation = expectation(description: "analytics send - success")
        sendExpectation.expectedFulfillmentCount = 1
        await dependencies.mockAnalytics.mock.updateSendCallback {
            sendExpectation.fulfill()
        }

        // Act
        let receivedToken = try await sut.createToken(paymentToken)

        // Assert
        XCTAssertEqual(receivedToken.id, ApplePayTokenStub.validToken.id)
        XCTAssertEqual(receivedToken.bin, ApplePayTokenStub.validToken.bin)
        let callCount = await useCaseMock.createTokenCallCount
        XCTAssertEqual(callCount, 1)

        await fulfillment(of: [sendExpectation], timeout: 1.0)

        // Verify analytics messages
        let messages = await dependencies.mockAnalytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.track(path: "/checkout_api_native/core_methods/tokenization")))
        XCTAssertTrue(messages.contains(.setEventData(["type_wallet": "applepay"])))
        XCTAssertTrue(messages.contains(.send))
    }

    func test_createToken_whenUseCaseFails_shouldThrowError() async {
        // Arrange
        let (sut, useCaseMock, dependencies) = makeSUT()
        let expectedError = APIErrorStub.genericError
        await useCaseMock.setCreateToken(result: .failure(expectedError))
        let paymentToken = PKPaymentToken()

        // Expect both initial "tokenization" send and error send
        let sendExpectation = expectation(description: "analytics send - error path")
        sendExpectation.expectedFulfillmentCount = 1
        await dependencies.mockAnalytics.mock.updateSendCallback {
            sendExpectation.fulfill()
        }

        // Act & Assert
        do {
            _ = try await sut.createToken(paymentToken)
            XCTFail("Expected createToken to throw an error, but it did not.")
        } catch {
            XCTAssertEqual(error as NSError, expectedError)
            let callCount = await useCaseMock.createTokenCallCount
            XCTAssertEqual(callCount, 1)
        }

        await fulfillment(of: [sendExpectation], timeout: 1.0)

        // Verify analytics includes error tracking
        let messages = await dependencies.mockAnalytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.track(path: "/checkout_api_native/core_methods/tokenization/error")))
        XCTAssertTrue(messages.contains(.setEventData(["type_wallet": "applepay"])))
        XCTAssertTrue(messages.contains(.setError(expectedError.localizedDescription)))
    }
}


// MARK: - Mock
private actor ApplePayUseCaseMock: @preconcurrency ApplePayUseCaseProtocol {
    private(set) var createTokenCallCount = 0
    private var createTokenResult: Result<MPApplePayToken, Error>!

    func setCreateToken(result: Result<MPApplePayToken, Error>) {
        createTokenResult = result
    }

    func createToken(_ payment: PKPaymentToken, status: String?) async throws -> MPApplePayToken {
        createTokenCallCount += 1
        switch createTokenResult {
        case .success(let token):
            return token
        case .failure(let error):
            throw error
        case .none:
            fatalError("Result not set")
        }
    }
} 
