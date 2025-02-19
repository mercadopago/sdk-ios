//
//  FetchSiteIDUseCaseTests.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 13/02/25.
//
import CommonTests
@testable import MPCore
import XCTest

// MARK: - Setup SUT

private extension FetchSiteIDUseCaseTests {
    typealias SUT = (
        sut: FetchSiteIDUseCase,
        session: MockURLSession,
        keyChain: MockKeyChainService
    )

    func makeSUT(
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) -> SUT {
        let dependencies = MockDependencyContainer()

        let session = dependencies.mockSession
        let keyChain = dependencies.mockKeyChainService

        let repository = SiteRepository(dependencies: dependencies)
        let sut = FetchSiteIDUseCase(dependencies: dependencies, repository: repository)

        return (sut, session, keyChain)
    }

    private func makeSuccessResponse(url: URL = URL(string: "http://example.com")!) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
}

final class FetchSiteIDUseCaseTests: XCTestCase {
    // MARK: - Cache Tests

    func test_getSiteID_WithCachedValue_ShouldReturnCachedValue() async {
        let publicKey = "test_public_key"
        let expectedSiteID = "MLA"

        let (sut, session, keyChain) = self.makeSUT()

        let data = try! JSONEncoder().encode(SiteResponse(id: expectedSiteID))

        await session.mock.setResponse(self.makeSuccessResponse())
        await session.mock.setData(data)

        let result = await sut.getSiteID(with: publicKey, and: .ARG)
        let resultCache = await sut.getSiteID(with: publicKey, and: .ARG)
        let messages = await keyChain.mock.getMessages()

        XCTAssertEqual(result, expectedSiteID)
        XCTAssertEqual(resultCache, expectedSiteID)
        XCTAssertEqual(messages, [.callRetrieve, .callSave, .callRetrieve])
    }

    // MARK: - Repository Tests

    func test_getSiteID_WithoutCache_ShouldFetchFromRepository() async {
        let expectedSiteID = "MLA"
        let (sut, session, _) = self.makeSUT()

        let data = try! JSONEncoder().encode(SiteResponse(id: expectedSiteID))

        await session.mock.setResponse(self.makeSuccessResponse())
        await session.mock.setData(data)

        let result = await sut.getSiteID(with: "teste_a", and: .ARG)

        XCTAssertEqual(result, expectedSiteID)
    }
}

extension FetchSiteIDUseCaseTests {
    // MARK: - Error Handling Tests

    func test_getSiteID_WithKeyChainError_ShouldReturnUnknown() async {
        let (sut, _, keyChain) = self.makeSUT()

        // Force keychain error
        await keyChain.mock.insertShouldThrowError(true)

        let result = await sut.getSiteID(with: "teste_key", and: .ARG)
        let messages = await keyChain.mock.getMessages()

        XCTAssertEqual(result, "MLA")
        XCTAssertEqual(messages, [.callRetrieve])
        XCTAssertEqual(sut.currentRetry, 0)
    }

    func test_getSiteID_WithEmptyKeyChain_ShouldFetchFromRepository() async {
        let expectedSiteID = "MCO"
        let publicKey = "test_key"
        let (sut, session, keyChain) = self.makeSUT()

        let data = try! JSONEncoder().encode(SiteResponse(id: expectedSiteID))
        await session.mock.setResponse(self.makeSuccessResponse())
        await session.mock.setData(data)

        let result = await sut.getSiteID(with: publicKey, and: .ARG)
        let messages = await keyChain.mock.getMessages()

        XCTAssertEqual(result, expectedSiteID)
        XCTAssertEqual(messages, [.callRetrieve, .callSave])
        XCTAssertEqual(sut.currentRetry, 0)
    }

    // MARK: - Network Error Tests

    func test_getSiteID_WithEmptyKeychainAndPersistentNetworkError_ShouldReturnUnknown() async {
        let (sut, session, keyChain) = self.makeSUT()

        let networkError = NSError(domain: "NetworkError", code: -1)
        await session.mock.setError(networkError)

        let result = await sut.getSiteID(with: "public_key", and: .ARG)
        let messages = await keyChain.mock.getMessages()

        XCTAssertEqual(result, "MLA")
        XCTAssertEqual(messages, [.callRetrieve, .callRetrieve, .callRetrieve, .callRetrieve])
        XCTAssertEqual(sut.currentRetry, 3)
    }

    // MARK: - Cache Storage Tests

    func test_getSiteID_SuccessfulFetch_ShouldStoreAndRetrieveFromCache() async {
        let expectedSiteID = "MPE"
        let publicKey = "test_public_key"
        let (sut, session, keyChain) = self.makeSUT()

        let data = try! JSONEncoder().encode(SiteResponse(id: expectedSiteID))
        await session.mock.setResponse(self.makeSuccessResponse())
        await session.mock.setData(data)

        let firstCallResult = await sut.getSiteID(with: publicKey, and: .ARG)
        let secondCallResult = await sut.getSiteID(with: publicKey, and: .ARG)
        let messages = await keyChain.mock.getMessages()

        XCTAssertEqual(firstCallResult, expectedSiteID)
        XCTAssertEqual(secondCallResult, expectedSiteID)
        XCTAssertEqual(messages, [
            .callRetrieve, // First call checks empty cache
            .callSave, // First call saves to cache
            .callRetrieve // Second call gets from cache
        ])
    }

    // MARK: - Invalid Response Tests

    func test_getSiteID_WithEmptyKeychainAndInvalidJSON_ShouldRetryAndEventuallyReturnUnknown() async {
        let (sut, session, keyChain) = self.makeSUT()

        await session.mock.setResponse(self.makeSuccessResponse())
        await session.mock.setData("invalid json".data(using: .utf8)!)

        let result = await sut.getSiteID(with: "test_key", and: .ARG)
        let messages = await keyChain.mock.getMessages()

        XCTAssertEqual(result, "MLA")
        XCTAssertEqual(messages, [.callRetrieve, .callRetrieve, .callRetrieve, .callRetrieve])
        XCTAssertEqual(sut.currentRetry, 3)
    }
}
