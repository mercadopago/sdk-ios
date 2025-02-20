@testable import CoreMethods
import Testing

import CommonTests
@testable import CoreMethods
import MPCore
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

    private func makeFailureResponse(url: URL = URL(string: "http://example.com")!) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)!
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

    func test_createToken_WhenNetworkReturnFailure_ShouldReturnDecodingError() async throws {
        let (sut, session) = self.makeSUT()
        let cardNumberField = await CardNumberTextField()
        let expirationDateField = await ExpirationDateTextfield()
        let securityCodeField = await SecurityCodeTextField()

        await session.mock.setResponse(self.makeFailureResponse())

        do {
            let _ = try await sut.createToken(
                cardNumber: cardNumberField,
                expirationDate: expirationDateField,
                securityCode: securityCodeField
            )
            XCTFail("Expected to throw APIClientError.decodingFailed error")
        } catch let error as APIClientError {
            guard case .decodingFailed = error else {
                XCTFail("Expected APIClientError.decodingFailed error but got \(error)")
                return
            }
        } catch {
            XCTFail("Expected APIClientError.decodingFailed error but got \(error)")
        }
    }

    func test_createToken_WhenNetworkReturnFailure_ShouldReturnAPIResponse() async {
        let (sut, session) = self.makeSUT()
        let cardNumberField = await CardNumberTextField()
        let expirationDateField = await ExpirationDateTextfield()
        let securityCodeField = await SecurityCodeTextField()
        let expectedResponse = APIErrorResponse(code: "400", message: "Bad Request")

        let data = try! JSONEncoder().encode(expectedResponse)

        await session.mock.setResponse(self.makeFailureResponse())
        await session.mock.setData(data)

        do {
            let _ = try await sut
                .createToken(
                    cardNumber: cardNumberField,
                    expirationDate: expirationDateField,
                    securityCode: securityCodeField
                )

            XCTFail("Expected to throw DecodingError but succeeded")
        } catch let error as APIClientError {
            if case let .apiError(errorResponse) = error {
                XCTAssertEqual(errorResponse, expectedResponse)
            } else {
                XCTFail("Expected .apiError but got \(error)")
            }
        } catch {
            XCTFail("Expected .apiError but got \(error)")
        }
    }

    func test_createToken_WhenPassingCardID_ShouldReturnCardToken() async {
        let (sut, session) = self.makeSUT()
        let cardID = "123"
        let securityCodeField = await SecurityCodeTextField()

        let data = try! JSONEncoder().encode(CardTokenResponse(id: "1234"))

        await session.mock.setResponse(self.makeSuccessResponse())
        await session.mock.setData(data)

        do {
            let result = try await sut
                .createToken(
                    cardID: cardID,
                    securityCode: securityCodeField
                )

            XCTAssertEqual(result.token, "1234")

        } catch {
            XCTFail("Expected sucess but got \(error)")
        }
    }
}
