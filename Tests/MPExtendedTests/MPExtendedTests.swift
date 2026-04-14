import CommonTests
@testable import MPExtended
import XCTest

@MainActor
final class MPExtendedTests: XCTestCase {
    // MARK: - Typealias

    private typealias SUT = (
        sut: MPExtended,
        useCase: DeviceSessionUseCaseMock
    )

    // MARK: - Stubs

    private enum SessionStub {
        static let validModel = MPDeviceSession(session: "device-session-abc123")
    }

    private enum APIErrorStub {
        static let genericError = NSError(domain: "test_domain", code: 1, userInfo: nil)
    }

    // MARK: - SUT Factory

    private func makeSUT(file _: StaticString = #filePath, line _: UInt = #line) -> SUT {
        let useCaseMock = DeviceSessionUseCaseMock()
        let sut = MPExtended(useCase: useCaseMock)
        return (sut: sut, useCase: useCaseMock)
    }

    // MARK: - Tests

    func test_deviceSession_whenUseCaseSucceeds_shouldReturnSession() async throws {
        // Arrange
        let (sut, useCaseMock) = self.makeSUT()
        await useCaseMock.setDeviceSession(result: .success(SessionStub.validModel))

        // Act
        let result = try await sut.deviceSession()

        // Assert
        XCTAssertEqual(result.session, SessionStub.validModel.session)
        let callCount = await useCaseMock.deviceSessionCallCount
        XCTAssertEqual(callCount, 1)
    }

    func test_deviceSession_whenUseCaseFails_shouldThrowError() async {
        // Arrange
        let (sut, useCaseMock) = self.makeSUT()
        let expectedError = APIErrorStub.genericError
        await useCaseMock.setDeviceSession(result: .failure(expectedError))

        // Act & Assert
        do {
            _ = try await sut.deviceSession()
            XCTFail("Expected deviceSession to throw an error, but it did not.")
        } catch {
            XCTAssertEqual(error as NSError, expectedError)
            let callCount = await useCaseMock.deviceSessionCallCount
            XCTAssertEqual(callCount, 1)
        }
    }
}

// MARK: - Mock

private actor DeviceSessionUseCaseMock: @preconcurrency DeviceSessionUseCaseProtocol {
    private(set) var deviceSessionCallCount = 0
    private var deviceSessionResult: Result<MPDeviceSession, Error>!

    func setDeviceSession(result: Result<MPDeviceSession, Error>) {
        self.deviceSessionResult = result
    }

    func deviceSession() async throws -> MPDeviceSession {
        self.deviceSessionCallCount += 1
        switch self.deviceSessionResult {
        case let .success(model):
            return model
        case let .failure(error):
            throw error
        case .none:
            fatalError("Result not set")
        }
    }
}
