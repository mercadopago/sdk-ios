@testable import CoreMethods
import Testing

import CommonTests
@testable import CoreMethods
import MPCoreTests
import XCTest

// MARK: - Setup SUT

private extension CoreMethodsTests {
    typealias SUT = (
        sut: CoreMethods,
        session: MockURLSession
    )

    func makeSUT(file _: StaticString = #filePath, line _: UInt = #line) -> SUT {
        let container = MockDependencyContainer()
        let session = container.mockSession
        let repository = CoreMethodsRepository(dependencies: container)

        let generateTokenUseCase = GenerateCardTokenUseCase(repository: repository)

        let sut = CoreMethods(generateTokenUseCase: generateTokenUseCase)

        return (sut, session)
    }

    private func makeSuccessResponse(url: URL = URL(string: "http://example.com")!) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
}

final class CoreMethodsTests: XCTestCase {
    func test_createToken_WhenNetworkReturnSucessful_ShouldReturnCardToken() async {
        let (sut, session) = self.makeSUT()
        let cardNumberField = await CardNumberTextField()
        let expirationDateField = await ExpirationDateTextfield()
        let securityCodeField = await SecurityCodeTextField()

        let data = try! JSONEncoder().encode(CardTokenResponse(id: "1234"))

        await session.mock.setResponse(self.makeSuccessResponse())
        await session.mock.setData(data)

        do {
            let result = try await sut
                .createToken(
                    cardNumber: cardNumberField,
                    expirationDate: expirationDateField,
                    securityCode: securityCodeField
                )

            XCTAssertEqual(result.token, "1234")

        } catch {
            XCTFail("Should not throw error")
        }
    }
}
