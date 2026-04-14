import CommonTests
@testable import MPCore
@testable import MPDevice
import XCTest

@MainActor
final class DeviceSessionUseCaseTests: XCTestCase {
    // MARK: - Typealias

    private typealias SUT = (
        sut: DeviceSessionUseCase,
        repository: MPDeviceRepositoryMock,
        fingerPrint: MockFingerPrint
    )

    // MARK: - Stubs

    private enum SessionStub {
        static let validString = "session-xyz-987"
    }

    private enum APIErrorStub {
        static let genericError = NSError(domain: "test_domain", code: 1, userInfo: nil)
    }

    private enum FingerPrintStub {
        static let validData = Data("""
        {
          "fingerprint": {
            "model": "iPhone16,1",
            "os": "ios",
            "vendorIds": [
              { "name": "idfv", "value": "C8E5B9F2-1234-5678-ABCD-DEADBEEF0001" }
            ],
            "vendorSpecificAttributes": {
              "brand": "Apple"
            }
          }
        }
        """.utf8)
    }

    // MARK: - SUT Factory

    private func makeSUT(file _: StaticString = #filePath, line _: UInt = #line) -> SUT {
        let fingerPrint = MockFingerPrint()
        let container = MockDependencyContainer(fingerPrint: fingerPrint)
        let repositoryMock = MPDeviceRepositoryMock()
        let useCase = DeviceSessionUseCase(dependencies: container, repository: repositoryMock)
        return (sut: useCase, repository: repositoryMock, fingerPrint: fingerPrint)
    }

    // MARK: - Tests

    func test_deviceSession_whenRepositorySucceeds_shouldReturnSession() async throws {
        // Arrange
        let (sut, repositoryMock, _) = self.makeSUT()
        await repositoryMock.setDeviceSession(result: .success(SessionStub.validString))

        // Act
        let result = try await sut.deviceSession()

        // Assert
        XCTAssertEqual(result.session, SessionStub.validString)
        let callCount = await repositoryMock.deviceSessionCallCount
        XCTAssertEqual(callCount, 1)
    }

    func test_deviceSession_whenFingerPrintIsNil_shouldSendNilFingerPrint() async throws {
        // Arrange
        let (sut, repositoryMock, _) = self.makeSUT()
        await repositoryMock.setDeviceSession(result: .success(SessionStub.validString))
        // MockFingerPrint returns nil by default

        // Act
        _ = try await sut.deviceSession()

        // Assert
        let body = await repositoryMock.lastBody
        XCTAssertNotNil(body)
        XCTAssertNil(body?.fingerPrint)
    }

    func test_deviceSession_whenFingerPrintHasValidData_shouldPassEntireFingerprintObject() async throws {
        // Arrange
        let fingerPrint = ConfigurableFingerPrint()
        await fingerPrint.setData(FingerPrintStub.validData)
        let container = FingerPrintOnlyContainer(fingerPrint: fingerPrint)
        let repositoryMock = MPDeviceRepositoryMock()
        let sut = DeviceSessionUseCase(dependencies: container, repository: repositoryMock)
        await repositoryMock.setDeviceSession(result: .success(SessionStub.validString))

        // Act
        _ = try await sut.deviceSession()

        // Assert
        let body = await repositoryMock.lastBody
        XCTAssertNotNil(body?.fingerPrint)
        XCTAssertEqual(body?.fingerPrint?["model"] as? String, "iPhone16,1")
        XCTAssertEqual(body?.fingerPrint?["os"] as? String, "ios")
        XCTAssertNotNil(body?.fingerPrint?["vendorIds"])
        XCTAssertNotNil(body?.fingerPrint?["vendorSpecificAttributes"])
    }

    func test_deviceSession_whenRepositoryFails_shouldThrowError() async {
        // Arrange
        let (sut, repositoryMock, _) = self.makeSUT()
        let expectedError = APIErrorStub.genericError
        await repositoryMock.setDeviceSession(result: .failure(expectedError))

        // Act & Assert
        do {
            _ = try await sut.deviceSession()
            XCTFail("Expected deviceSession to throw an error, but it did not.")
        } catch {
            XCTAssertEqual(error as NSError, expectedError)
            let callCount = await repositoryMock.deviceSessionCallCount
            XCTAssertEqual(callCount, 1)
        }
    }
}

// MARK: - Mocks

private struct FingerPrintOnlyContainer: HasFingerPrint {
    let fingerPrint: FingerPrintProtocol
}

private actor ConfigurableFingerPrint: @preconcurrency FingerPrintProtocol {
    private var data: Data?

    func setData(_ data: Data) {
        self.data = data
    }

    func getDeviceData() async -> Data? {
        return self.data
    }
}

private actor MPDeviceRepositoryMock: MPDeviceRepositoryProtocol {
    private(set) var deviceSessionCallCount = 0
    private(set) var lastBody: DeviceSessionBody?
    private var deviceSessionResult: Result<String, Error>!

    func setDeviceSession(result: Result<String, Error>) {
        self.deviceSessionResult = result
    }

    func deviceSession(body: DeviceSessionBody) async throws -> String {
        self.deviceSessionCallCount += 1
        self.lastBody = body
        switch self.deviceSessionResult {
        case let .success(session):
            return session
        case let .failure(error):
            throw error
        case .none:
            fatalError("Result not set")
        }
    }
}
