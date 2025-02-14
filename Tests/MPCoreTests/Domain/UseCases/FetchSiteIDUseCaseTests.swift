//
//  FetchSiteIDUseCaseTests.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 13/02/25.
//
@testable import MPCore
import XCTest

// MARK: - Test Doubles

private final class MockKeyChainService: KeyChainManagerProtocol {
    actor Mock {
        enum Messages {
            case callSave
            case callRetrieve
        }

        var messages: [Messages] = []

        var savedData: [String: String] = [:]
        var shouldThrowError = false

        func insert(value: String, account: String) {
            self.savedData[account] = value
        }

        func get(account: String) -> String? {
            return self.savedData[account]
        }

        func insertMesseges(_ message: Messages) {
            self.messages.append(message)
        }

        func getMessages() -> [Messages] {
            return self.messages
        }

        func insertShouldThrowError(_ value: Bool) {
            self.shouldThrowError = value
        }
    }

    let mock = Mock()

    func save(_ value: String, account: String) async throws {
        if await self.mock.shouldThrowError {
            throw NSError(domain: "KeyChainError", code: -1)
        }
        await self.mock.insertMesseges(.callSave)

        await self.mock.insert(value: value, account: account)
    }

    func retrieve(account: String) async throws -> String? {
        await self.mock.insertMesseges(.callRetrieve)

        if await self.mock.shouldThrowError {
            throw NSError(domain: "KeyChainError", code: -1)
        }

        return await self.mock.get(account: account)
    }

    func delete(account _: String) async throws {
        print("error teste")
    }
}

private struct MockDependencyContainer: Sendable, HasKeyChain, HasNetwork {
    let keyChainService: KeyChainManagerProtocol

    let networkService: NetworkServiceProtocol

    init(
        session: URLSessionProtocol,
        keyChainService: KeyChainManagerProtocol = MockKeyChainService()
    ) {
        self.networkService = NetworkService(session: session)
        self.keyChainService = keyChainService
    }
}

// MARK: - Setup SUT

private extension FetchSiteIDUseCaseTests {
    typealias SUT = (sut: FetchSiteIDUseCase, session: MockURLSession, keyChain: MockKeyChainService)

    func makeSUT(
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) -> SUT {
        let session = MockURLSession()
        let keyChain = MockKeyChainService()
        let dependencies = MockDependencyContainer(session: session, keyChainService: keyChain)
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

        let result = await sut.getSiteID(by: publicKey)
        let resultCache = await sut.getSiteID(by: publicKey)
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

        let result = await sut.getSiteID(by: "test_key")

        XCTAssertEqual(result, expectedSiteID)
    }
}

extension FetchSiteIDUseCaseTests {
    // MARK: - Error Handling Tests

    func test_getSiteID_WithKeyChainError_ShouldReturnUnknown() async {
        let (sut, _, keyChain) = self.makeSUT()

        // Force keychain error
        await keyChain.mock.insertShouldThrowError(true)

        let result = await sut.getSiteID(by: "test_key")
        let messages = await keyChain.mock.getMessages()

        XCTAssertEqual(result, "unknown")
        XCTAssertEqual(messages, [.callRetrieve])
        XCTAssertEqual(sut.currentRetry, 0) // Não deve ter feito retry
    }

    func test_getSiteID_WithEmptyKeyChain_ShouldFetchFromRepository() async {
        let expectedSiteID = "MCO"
        let publicKey = "test_key"
        let (sut, session, keyChain) = self.makeSUT()

        // Setup successful repository response
        let data = try! JSONEncoder().encode(SiteResponse(id: expectedSiteID))
        await session.mock.setResponse(self.makeSuccessResponse())
        await session.mock.setData(data)

        let result = await sut.getSiteID(by: publicKey)
        let messages = await keyChain.mock.getMessages()

        XCTAssertEqual(result, expectedSiteID)
        XCTAssertEqual(messages, [.callRetrieve, .callSave])
        XCTAssertEqual(sut.currentRetry, 0)
    }

    // MARK: - Network Error Tests

    func test_getSiteID_WithEmptyKeychainAndPersistentNetworkError_ShouldReturnUnknown() async {
        let (sut, session, keyChain) = self.makeSUT()

        // Simulate persistent network error
        let networkError = NSError(domain: "NetworkError", code: -1)
        await session.mock.setError(networkError)

        let result = await sut.getSiteID(by: "test_key")
        let messages = await keyChain.mock.getMessages()

        XCTAssertEqual(result, "unknown")
        XCTAssertEqual(messages, [.callRetrieve, .callRetrieve, .callRetrieve, .callRetrieve])
        XCTAssertEqual(sut.currentRetry, 3)
    }

    // MARK: - Cache Storage Tests

    func test_getSiteID_SuccessfulFetch_ShouldStoreAndRetrieveFromCache() async {
        let expectedSiteID = "MPE"
        let publicKey = "test_public_key"
        let (sut, session, keyChain) = self.makeSUT()

        // Primeira chamada - keychain vazio, busca do repository
        let data = try! JSONEncoder().encode(SiteResponse(id: expectedSiteID))
        await session.mock.setResponse(self.makeSuccessResponse())
        await session.mock.setData(data)

        let firstCallResult = await sut.getSiteID(by: publicKey)
        let secondCallResult = await sut.getSiteID(by: publicKey)
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

        // Set invalid JSON response
        await session.mock.setResponse(self.makeSuccessResponse())
        await session.mock.setData("invalid json".data(using: .utf8)!)

        let result = await sut.getSiteID(by: "test_key")
        let messages = await keyChain.mock.getMessages()

        XCTAssertEqual(result, "unknown")
        XCTAssertEqual(messages, [.callRetrieve, .callRetrieve, .callRetrieve, .callRetrieve])
        XCTAssertEqual(sut.currentRetry, 3)
    }
}
