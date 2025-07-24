
import XCTest
import PassKit
@testable import MPApplePay

extension PKPaymentToken: @unchecked @retroactive Sendable {}

final class MPApplePayTests: XCTestCase {

    // MARK: - Typealias
    private typealias SUT = (
        sut: MPApplePay,
        useCase: ApplePayUseCaseMock
    )

    // MARK: - Stubs
    private enum ApplePayTokenStub {
        static let validToken = MPApplePayToken(
            token: "token_data"
        )
    }

    private enum APIErrorStub {
        static let genericError = NSError(domain: "test_domain", code: 1, userInfo: nil)
    }

    // MARK: - SUT Factory
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
        let useCaseMock = ApplePayUseCaseMock()
        let sut = MPApplePay(useCaseMock)
        return (sut: sut, useCase: useCaseMock)
    }

    // MARK: - Tests
    func test_createToken_whenUseCaseSucceeds_shouldReturnToken() async throws {
        // Arrange
        let (sut, useCaseMock) = makeSUT()
        await useCaseMock.setCreateToken(result: .success(ApplePayTokenStub.validToken))
        let paymentToken = PKPaymentToken()

        // Act
        let receivedToken = try await sut.createToken(paymentToken)

        // Assert
        XCTAssertEqual(receivedToken.token, ApplePayTokenStub.validToken.token)
        let callCount = await useCaseMock.createTokenCallCount
        XCTAssertEqual(callCount, 1)
    }

    func test_createToken_whenUseCaseFails_shouldThrowError() async {
        // Arrange
        let (sut, useCaseMock) = makeSUT()
        let expectedError = APIErrorStub.genericError
        await useCaseMock.setCreateToken(result: .failure(expectedError))
        let paymentToken = PKPaymentToken()

        // Act & Assert
        do {
            _ = try await sut.createToken(paymentToken)
            XCTFail("Expected createToken to throw an error, but it did not.")
        } catch {
            XCTAssertEqual(error as NSError, expectedError)
            let callCount = await useCaseMock.createTokenCallCount
            XCTAssertEqual(callCount, 1)
        }
    }
}


// MARK: - Mock
private actor ApplePayUseCaseMock: @preconcurrency ApplePayUseCaseProtocol {
    private(set) var createTokenCallCount = 0
    private var createTokenResult: Result<MPApplePayToken, Error>!

    func setCreateToken(result: Result<MPApplePayToken, Error>) {
        createTokenResult = result
    }

    func createToken(_ payment: PKPaymentToken) async throws -> MPApplePayToken {
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
