
import XCTest
import PassKit
@testable import MPApplePay

final class ApplePayUseCaseTests: XCTestCase {

    // MARK: - Typealias
    private typealias SUT = (
        sut: ApplePayUseCase,
        repository: ApplePayRepositoryMock
    )

    // MARK: - Stubs
    private enum ApplePayTokenStub {
        static let validToken = MPApplePayToken(id: "some_token_id", bin: "123456")
    }

    private enum APIErrorStub {
        static let genericError = NSError(domain: "test_domain", code: 1, userInfo: nil)
    }

    // MARK: - SUT Factory
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
        let repositoryMock = ApplePayRepositoryMock()
        let useCase = ApplePayUseCase(repository: repositoryMock)
        return (sut: useCase, repository: repositoryMock)
    }

    // MARK: - Tests
    func test_createToken_whenRepositorySucceeds_shouldReturnToken() async throws {
        // Arrange
        let (sut, repositoryMock) = makeSUT()
        await repositoryMock.setCreateToken(result: .success(ApplePayTokenStub.validToken))
        let paymentToken = PKPaymentToken()

        // Act
        let receivedToken = try await sut.createToken(paymentToken)

        // Assert
        XCTAssertEqual(receivedToken.id, ApplePayTokenStub.validToken.id)
        XCTAssertEqual(receivedToken.bin, ApplePayTokenStub.validToken.bin)
        
        let callCount = await repositoryMock.createTokenCallCount
        XCTAssertEqual(callCount, 1)
    }

    func test_createToken_whenRepositoryFails_shouldThrowError() async {
        // Arrange
        let (sut, repositoryMock) = makeSUT()
        let expectedError = APIErrorStub.genericError
        await repositoryMock.setCreateToken(result: .failure(expectedError))
        let paymentToken = PKPaymentToken()

        // Act & Assert
        do {
            _ = try await sut.createToken(paymentToken)
            XCTFail("Expected createToken to throw an error, but it did not.")
        } catch {
            XCTAssertEqual(error as NSError, expectedError)
            
            let callCount = await repositoryMock.createTokenCallCount
            XCTAssertEqual(callCount, 1)
        }
    }
}


// MARK: - Mock
private actor ApplePayRepositoryMock: ApplePayRepositoryProtocol {

    private(set) var createTokenCallCount = 0
    private var createTokenResult: Result<MPApplePayToken, Error>!

    func setCreateToken(result: Result<MPApplePayToken, Error>) {
        self.createTokenResult = result
    }

    func createToken(payment: PKPaymentToken) async throws -> MPApplePayToken {
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
