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
        if await self.mock.shouldThrowError {
            throw NSError(domain: "KeyChainError", code: -1)
        }
        await self.mock.insertMesseges(.callRetrieve)

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
    ///    // MARK: - Cache Tests
    ///
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
