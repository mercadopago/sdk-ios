//
//  GenerateCardTokenUseCase.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 18/02/25.
//
import CommonTests
@testable import CoreMethods
import XCTest

// MARK: - Setup SUT

private extension GenerateCardTokenUseCaseTests {
    typealias SUT = (
        sut: GenerateCardTokenUseCase,
        session: MockURLSession
    )

    func makeSUT(file _: StaticString = #filePath, line _: UInt = #line) -> SUT {
        let container = MockDependencyContainer()
        let session = container.mockSession
        let repository = CoreMethodsRepository(dependencies: container)

        let sut = GenerateCardTokenUseCase(dependencies: container, repository: repository)

        return (sut, session)
    }

    private func makeSuccessResponse(url: URL = URL(string: "http://example.com")!) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
}

final class GenerateCardTokenUseCaseTests: XCTestCase {
    func test_tokenize_WhenNetworkReturnSucessful_ShouldReturnCardToken() async {
        let (sut, session) = self.makeSUT()

        let data = try! JSONEncoder().encode(CardTokenResponse(id: "1234"))

        await session.mock.setResponse(self.makeSuccessResponse())
        await session.mock.setData(data)

        do {
            let result = try await sut.tokenize(
                cardNumber: "411111111111",
                expirationDateMonth: "12",
                expirationDateYear: "2032",
                securityCodeInput: "123",
                cardID: nil,
                cardHolderName: nil,
                identificationType: nil,
                identificationNumber: nil
            )

            XCTAssertEqual(result.token, "1234")

        } catch {
            XCTFail("Should not throw error")
        }
    }
}
