import CommonTests
@testable import MPCore
@testable import MPExtended
import XCTest

@MainActor
final class MPExtendedRepositoryTests: XCTestCase {
    // MARK: - Typealias

    private typealias SUT = (
        sut: MPExtendedRepository,
        dependencies: MockDependencyContainer
    )

    // MARK: - Stubs

    private enum BodyStub {
        static let valid = DeviceSessionBody(
            siteId: "MLA",
            fingerPrint: ["model": "iPhone", "os": "ios"]
        )
    }

    // MARK: - SUT Factory

    private func makeSUT(file _: StaticString = #filePath, line _: UInt = #line) -> SUT {
        let dependencies = MockDependencyContainer()
        let sut = MPExtendedRepository(dependencies: dependencies)
        return (sut, dependencies)
    }

    // MARK: - Tests

    func test_deviceSession_whenNetworkSucceeds_shouldReturnSessionString() async throws {
        // Arrange
        let (sut, dependencies) = self.makeSUT()

        let expectedResponse = DeviceSessionResponse(session: "session-token-123")
        let data = try JSONEncoder().encode(expectedResponse)
        let url = try XCTUnwrap(URL(string: "https://api.mercadopago.com/cho-off/v1/devices/session"))
        let response = try XCTUnwrap(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil))
        await dependencies.mockSession.mock.setData(data)
        await dependencies.mockSession.mock.setResponse(response)

        // Act
        let session = try await sut.deviceSession(body: BodyStub.valid)

        // Assert
        XCTAssertEqual(session, expectedResponse.session)
    }

    func test_deviceSession_whenNetworkFails_shouldPropagateError() async {
        // Arrange
        let (sut, dependencies) = self.makeSUT()
        let expectedError = URLError(.notConnectedToInternet)
        await dependencies.mockSession.mock.setError(expectedError)

        // Act & Assert
        do {
            _ = try await sut.deviceSession(body: BodyStub.valid)
            XCTFail("Expected error to be thrown")
        } catch let error as APIClientError {
            guard case let .networkError(inner as URLError) = error else {
                return XCTFail("Expected networkError, got: \(error)")
            }
            XCTAssertEqual(inner.code, .notConnectedToInternet)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_deviceSession_whenResponseDecodingFails_shouldThrowDecodingError() async throws {
        // Arrange
        let (sut, dependencies) = self.makeSUT()
        let invalidData = Data("invalid_json".utf8)
        let url = try XCTUnwrap(URL(string: "https://api.mercadopago.com/cho-off/v1/devices/session"))
        let response = try XCTUnwrap(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil))
        await dependencies.mockSession.mock.setData(invalidData)
        await dependencies.mockSession.mock.setResponse(response)

        // Act & Assert
        do {
            _ = try await sut.deviceSession(body: BodyStub.valid)
            XCTFail("Expected decoding error to be thrown")
        } catch let error as APIClientError {
            guard case .decodingFailed = error else {
                return XCTFail("Expected decodingFailed, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
