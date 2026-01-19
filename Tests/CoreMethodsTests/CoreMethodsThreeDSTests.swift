import CommonTests
@testable import CoreMethods
import MPCore
import XCTest

/// Tests for ThreeDS helpers in `CoreMethods` using a repository mock to inspect payloads.
final class CoreMethodsThreeDSTests: XCTestCase {
    // MARK: - Types
    typealias SUT = (
        coreMethods: CoreMethods,
        repository: MockThreeDSRepository
    )
    
    // MARK: - Setup
    private func makeSUT() -> SUT {
        let container = MockDependencyContainer()
        let coreRepository = CoreMethodsRepository(dependencies: container)
        let threeDSRepository = MockThreeDSRepository()
        let capabilityUseCase = CapabilityUseCase(repository: threeDSRepository)
        var configuration = CoreMethods.Configuration()
        configuration.threeDS.sdkVersion = "2.2.0"

        let sut = CoreMethods(
            dependencies: container,
            generateTokenUseCase: GenerateCardTokenUseCase(dependencies: container, repository: coreRepository),
            identificationTypeUseCase: IdentificationTypesUseCase(repository: coreRepository),
            installmentsUseCase: InstallmentsUseCase(repository: coreRepository),
            paymentMethodUseCase: PaymentMethodUseCase(repository: coreRepository),
            issuerUseCase: IssuerUseCase(repository: coreRepository),
            capabilityUseCase: capabilityUseCase,
            configuration: configuration
        )

        return (sut, threeDSRepository)
    }
    
    // MARK: - Tests
    func test_sendDeviceData_shouldMapPayloadToRepository() async throws {
        // Arrange
        let (sut, repository) = makeSUT()
        let ephemeral = #"{"crv":"P-256","kty":"EC","x":"x-val","y":"y-val"}"#
        
        // Act
        try await sut.sendDeviceData(
            cardTokenId: "token",
            appId: "app",
            deviceData: "device-data",
            referenceNumber: "ref",
            ephemeralPublicKey: ephemeral,
            transactionID: "trans"
        )
        
        
        // Assert
        let body = repository.postCalls.last?.body
        XCTAssertEqual(body?.cardTokenId, "token")
        XCTAssertEqual(body?.appId, "app")
        XCTAssertEqual(body?.encData, "device-data")
        XCTAssertEqual(body?.threeDSSDKVersion, "2.2.0")
        XCTAssertEqual(body?.referenceNumber, "ref")
        XCTAssertEqual(body?.transId, "trans")
        XCTAssertEqual(body?.protocolVersion, CoreMethods.Configuration().threeDS.protocolVersion)
        XCTAssertEqual(body?.maxTimeout, CoreMethods.Configuration().threeDS.maxTimeout)
        XCTAssertEqual(body?.deviceRenderOptions.interface, CoreMethods.Configuration().threeDS.deviceRenderOptions.interface.rawValue)
        XCTAssertEqual(body?.deviceRenderOptions.uiTypes, CoreMethods.Configuration().threeDS.deviceRenderOptions.uiTypes)
        XCTAssertEqual(body?.ephemPubKey.curve, "P-256")
        XCTAssertEqual(body?.ephemPubKey.keyType, "EC")
        XCTAssertEqual(body?.ephemPubKey.xEphem, "x-val")
        XCTAssertEqual(body?.ephemPubKey.yEphem, "y-val")
    }
    
    func test_sendDeviceData_whenRepositoryThrows_shouldPropagateError() async {
        // Arrange
        let (sut, repository) = makeSUT()
        repository.postError = MPThreeDSError.failedToSendDeviceData
        
        // Act & Assert
        do {
            try await sut.sendDeviceData(
                cardTokenId: "token",
                appId: "app",
                deviceData: "device-data",
                referenceNumber: "ref",
                ephemeralPublicKey: "{}",
                transactionID: "trans"
            )
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is MPThreeDSError)
        }
    }
    
    func test_challengeParameters_shouldMapRepositoryResponse() async throws {
        // Arrange
        let (sut, repository) = makeSUT()
        repository.getResult = MPThreeDSChallengeResponse(
            status: "challenge",
            data: .init(
                threeDSServerTransID: "ds-trans",
                acsReferenceNumber: "acs-ref",
                acsTransID: "acs-trans",
                acsSignedContent: "signed-content"
            )
        )
        
        // Act
        let result = try await sut.challengeParameters("challenge-id")
        
        // Assert
        XCTAssertEqual(repository.getCalls.last?.id, "challenge-id")
        XCTAssertEqual(result.status, .challenge)
        XCTAssertEqual(result.acsReferenceNumber, "acs-ref")
        XCTAssertEqual(result.dsTransID, "ds-trans")
        XCTAssertEqual(result.acsTransID, "acs-trans")
        XCTAssertEqual(result.acsSignedContent, "signed-content")
    }
    
    func test_finishChallenge_shouldSendCompletedStatus() async throws {
        // Arrange
        let (sut, repository) = makeSUT()
        
        // Act
        try await sut.finishChallenge("id-1")
        
        // Assert
        XCTAssertEqual(repository.patchCalls.last?.id, "id-1")
        XCTAssertEqual(repository.patchCalls.last?.body.status, .completed)
        XCTAssertNil(repository.patchCalls.last?.body.errorDetail)
    }
    
    func test_cancelChallenge_shouldSendCancelledStatus() async throws {
        // Arrange
        let (sut, repository) = makeSUT()
        
        // Act
        try await sut.cancelChallenge("id-2")
        
        // Assert
        XCTAssertEqual(repository.patchCalls.last?.id, "id-2")
        XCTAssertEqual(repository.patchCalls.last?.body.status, .cancelled)
        XCTAssertNil(repository.patchCalls.last?.body.errorDetail)
    }
    
    func test_errorChallenge_shouldSendErrorStatusWithDetails() async throws {
        // Arrange
        let (sut, repository) = makeSUT()
        
        // Act
        try await sut.errorChallenge("id-3", errorCode: "123", errorMessageType: "type")
        
        // Assert
        let call = repository.patchCalls.last
        XCTAssertEqual(call?.id, "id-3")
        XCTAssertEqual(call?.body.status, .error)
        XCTAssertEqual(call?.body.errorDetail?.code, "123")
        XCTAssertEqual(call?.body.errorDetail?.type, "type")
    }
    
    func test_timeoutChallenge_shouldSendTimeoutStatus() async throws {
        // Arrange
        let (sut, repository) = makeSUT()
        
        // Act
        try await sut.timeoutChallenge("id-4")
        
        // Assert
        XCTAssertEqual(repository.patchCalls.last?.id, "id-4")
        XCTAssertEqual(repository.patchCalls.last?.body.status, .timeout)
        XCTAssertNil(repository.patchCalls.last?.body.errorDetail)
    }
    
    func test_patchChallenge_whenRepositoryThrows_shouldPropagateError() async {
        // Arrange
        let (sut, repository) = makeSUT()
        repository.patchError = DummyError.sample
        
        // Act & Assert
        do {
            try await sut.finishChallenge("id-error")
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is DummyError)
        }
    }
    
    // MARK: - Helpers
    enum DummyError: Error {
        case sample
    }
}

