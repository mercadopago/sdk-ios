import XCTest
import PassKit
import CommonTests
@testable import MPCore
@testable import MPApplePay

extension PKPaymentToken: @unchecked @retroactive Sendable {}

final class MPApplePayRepositoryTests: XCTestCase {

    private typealias SUT = (
        sut: MPApplePayRepository,
        dependencies: MockDependencyContainer
    )

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
        let dependencies = MockDependencyContainer()
        let sut = MPApplePayRepository(dependencies: dependencies)
        return (sut, dependencies)
    }

    func test_createToken_whenNetworkSucceeds_shouldMapResponseToPublicModel() async throws {
        // Arrange
        let (sut, dependencies) = makeSUT()

        let expectedResponse = MPTokenResponse(id: "bdbd575d450c191c1e0c6c8e302d5eb0", bin: "123456")
        let data = try JSONEncoder().encode(expectedResponse)
        let url = URL(string: "https://api.mercadopago.com/platforms/pci/applepay/v1/tokenize")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        await dependencies.mockSession.mock.setData(data)
        await dependencies.mockSession.mock.setResponse(response)

        let paymentToken = PKPaymentToken()

        // Act
        let token = try await sut.createToken(payment: paymentToken, status: nil, device:  Data())

        // Assert
        XCTAssertEqual(token.id, expectedResponse.id)
        XCTAssertEqual(token.bin, expectedResponse.bin)
    }

    func test_createToken_whenNetworkFails_shouldPropagateError() async {
        // Arrange
        let (sut, dependencies) = makeSUT()
        let expectedError = URLError(.timedOut)
        await dependencies.mockSession.mock.setError(expectedError)
        let paymentToken = PKPaymentToken()

        // Act & Assert
        do {
            _ = try await sut.createToken(payment: paymentToken, status: nil, device: Data())
            XCTFail("Expected error to be thrown")
        } catch let error as APIClientError {
            guard case let .networkError(inner as URLError) = error else {
                return XCTFail("Expected networkError, got: \(error)")
            }
            XCTAssertEqual(inner.code, .timedOut)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}


