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
        session: MockURLSession
    )

    func makeSUT(
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) -> SUT {
        let dependencies = MockDependencyContainer()

        let session = dependencies.mockSession

        let repository = SiteRepository(dependencies: dependencies)
        let sut = FetchSiteIDUseCase(dependencies: dependencies, repository: repository)

        return (sut, session)
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

        let (sut, session) = self.makeSUT()

        let data = try! JSONEncoder().encode(SiteResponse(id: expectedSiteID))

        await session.mock.setResponse(self.makeSuccessResponse())
        await session.mock.setData(data)

        let result = await sut.getSiteID(with: publicKey, and: .ARG)
        let resultCache = await sut.getSiteID(with: publicKey, and: .ARG)

        XCTAssertEqual(result, expectedSiteID)
        XCTAssertEqual(resultCache, expectedSiteID)
    }

    // MARK: - Repository Tests

    func test_getSiteID_WithoutCache_ShouldFetchFromRepository() async {
        let expectedSiteID = "MLA"
        let (sut, session) = self.makeSUT()

        let data = try! JSONEncoder().encode(SiteResponse(id: expectedSiteID))

        await session.mock.setResponse(self.makeSuccessResponse())
        await session.mock.setData(data)

        let result = await sut.getSiteID(with: "teste_a", and: .ARG)

        XCTAssertEqual(result, expectedSiteID)
    }
}

extension FetchSiteIDUseCaseTests {
    // MARK: - Error Handling Tests

    func test_getSiteID_WithPersistentNetworkError_ShouldReturnCountryDefaultAndMaxRetries() async {
        let (sut, session) = self.makeSUT()

        let networkError = NSError(domain: "NetworkError", code: -1)
        await session.mock.setError(networkError)

        let result = await sut.getSiteID(with: "public_key", and: .ARG)

        XCTAssertEqual(result, "MLA")
        XCTAssertEqual(sut.currentRetry, 3)
    }

    // MARK: - Network Error Tests

    func test_getSiteID_WithInvalidJSON_ShouldRetryAndEventuallyReturnCountryDefault() async {
        let (sut, session) = self.makeSUT()

        await session.mock.setResponse(self.makeSuccessResponse())
        await session.mock.setData("invalid json".data(using: .utf8)!)

        let result = await sut.getSiteID(with: "test_key", and: .ARG)

        XCTAssertEqual(result, "MLA")
        XCTAssertEqual(sut.currentRetry, 3)
    }

    // MARK: - Cache Storage Tests

    func test_getSiteID_SuccessfulFetch_TwoConsecutiveCallsReturnSameValue() async {
        let expectedSiteID = "MPE"
        let publicKey = "test_public_key"
        let (sut, session) = self.makeSUT()

        let data = try! JSONEncoder().encode(SiteResponse(id: expectedSiteID))
        await session.mock.setResponse(self.makeSuccessResponse())
        await session.mock.setData(data)

        let firstCallResult = await sut.getSiteID(with: publicKey, and: .ARG)
        let secondCallResult = await sut.getSiteID(with: publicKey, and: .ARG)

        XCTAssertEqual(firstCallResult, expectedSiteID)
        XCTAssertEqual(secondCallResult, expectedSiteID)
    }
}
