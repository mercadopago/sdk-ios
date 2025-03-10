import CommonTests
@testable import CoreMethods
import MPCore
import Testing
import XCTest

// MARK: - CoreMethodsTests

final class CoreMethodsTests: XCTestCase {
    // MARK: - Types

    typealias SUT = (
        coreMethodsService: CoreMethods,
        session: MockURLSession,
        analytics: MockAnalytics
    )

    // MARK: - Stubs and Factories

    /// Card token response model
    private enum CardTokenStub {
        static let validTokenID = "1234"

        static var validResponse: Data {
            try! JSONEncoder().encode(CardTokenResponse(id: validTokenID))
        }
    }

    /// Identification type response model
    private enum IdentificationTypeStub {
        static let validDNI = IdentificationType(
            id: "DNI",
            name: "DNI",
            type: "number",
            minLenght: 7,
            maxLenght: 8
        )

        static var validResponse: Data {
            let response = """
            [
              {
                "id": "DNI",
                "name": "DNI",
                "type": "number",
                "min_length": 7,
                "max_length": 8
              }
            ]
            """
            return Data(response.utf8)
        }

        static var expectedTypes: [IdentificationType] {
            [validDNI]
        }
    }

    /// API error response model
    private enum APIErrorStub {
        static let badRequest = APIErrorResponse(code: "400", message: "Bad Request")

        static var badRequestData: Data {
            try! JSONEncoder().encode(badRequest)
        }
    }

    // MARK: - HTTPURLResponse Factory

    private func makeHTTPResponse(statusCode: Int, url: URL = URL(string: "http://example.com")!) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }

    // MARK: - Card Fields Factory

    private func makeCardFields() async -> (
        cardNumber: CardNumberTextField,
        expirationDate: ExpirationDateTextfield,
        securityCode: SecurityCodeTextField
    ) {
        let cardNumberField = await CardNumberTextField()
        let expirationDateField = await ExpirationDateTextfield()
        let securityCodeField = await SecurityCodeTextField()

        return (cardNumberField, expirationDateField, securityCodeField)
    }

    // MARK: - Setup SUT

    private func makeSUT(file _: StaticString = #filePath, line _: UInt = #line) -> SUT {
        let container = MockDependencyContainer()
        let session = container.mockSession
        let analytics = container.mockAnalytics

        let repository = CoreMethodsRepository(dependencies: container)

        let generateTokenUseCase = GenerateCardTokenUseCase(repository: repository)
        let identificationTypeUseCase = IdentificationTypesUseCase(repository: repository)

        let coreMethodsService = CoreMethods(
            dependencies: container,
            generateTokenUseCase: generateTokenUseCase,
            identificationTypeUseCase: identificationTypeUseCase
        )

        return (coreMethodsService, session, analytics)
    }

    // MARK: - Error assertion helpers

    private func assertThrowsAPIError(
        _ expression: @autoclosure () async throws -> Any,
        expectedError: APIErrorResponse,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            let _ = try await expression()
            XCTFail("Should have thrown an error, but succeeded", file: file, line: line)
        } catch let error as APIClientError {
            if case let .apiError(errorResponse) = error {
                XCTAssertEqual(errorResponse, expectedError, "API error does not match expected", file: file, line: line)
            } else {
                XCTFail("Expected .apiError but got \(error)", file: file, line: line)
            }
        } catch {
            XCTFail("Expected APIClientError but got \(error)", file: file, line: line)
        }
    }

    // MARK: - Tests for createToken with complete card data

    func test_createToken_whenNetworkReturnsSuccess_shouldReturnCardToken() async {
        // Arrange
        let (sut, session, _) = self.makeSUT()
        let (cardNumber, expirationDate, securityCode) = await makeCardFields()

        await session.mock.setResponse(self.makeHTTPResponse(statusCode: 200))
        await session.mock.setData(CardTokenStub.validResponse)

        // Act
        do {
            let result = try await sut.createToken(
                cardNumber: cardNumber,
                expirationDate: expirationDate,
                securityCode: securityCode
            )

            // Assert
            XCTAssertEqual(result.token, CardTokenStub.validTokenID)
        } catch {
            XCTFail("Should not throw error: \(error)")
        }
    }

    func test_createToken_whenNetworkReturnsError_shouldThrowDecodingError() async {
        // Arrange
        let (sut, session, _) = self.makeSUT()
        let (cardNumber, expirationDate, securityCode) = await makeCardFields()

        await session.mock.setResponse(self.makeHTTPResponse(statusCode: 200))
        await session.mock.setData(Data()) // Empty data to force decoding error

        // Act & Assert
        do {
            let _ = try await sut.createToken(
                cardNumber: cardNumber,
                expirationDate: expirationDate,
                securityCode: securityCode
            )
            XCTFail("Expected APIClientError.decodingFailed error")
        } catch let error as APIClientError {
            guard case .decodingFailed = error else {
                XCTFail("Expected APIClientError.decodingFailed error but got \(error)")
                return
            }
        } catch {
            XCTFail("Expected APIClientError.decodingFailed error but got \(error)")
        }
    }

    func test_createToken_whenNetworkReturnsFormattedError_shouldThrowAPIErrorResponse() async {
        // Arrange
        let (sut, session, _) = self.makeSUT()
        let (cardNumber, expirationDate, securityCode) = await makeCardFields()

        await session.mock.setResponse(self.makeHTTPResponse(statusCode: 400))
        await session.mock.setData(APIErrorStub.badRequestData)

        // Act & Assert
        try await self.assertThrowsAPIError(
            await sut.createToken(
                cardNumber: cardNumber,
                expirationDate: expirationDate,
                securityCode: securityCode
            ),
            expectedError: APIErrorStub.badRequest
        )
    }

    // MARK: - Tests for createToken with cardID

    func test_createToken_withValidCardID_shouldReturnCardToken() async {
        // Arrange
        let (sut, session, _) = self.makeSUT()
        let cardID = "123"
        let securityCode = await SecurityCodeTextField()

        await session.mock.setResponse(self.makeHTTPResponse(statusCode: 200))
        await session.mock.setData(CardTokenStub.validResponse)

        // Act
        do {
            let result = try await sut.createToken(
                cardID: cardID,
                securityCode: securityCode
            )

            // Assert
            XCTAssertEqual(result.token, CardTokenStub.validTokenID)
        } catch {
            XCTFail("Expected success but got \(error)")
        }
    }

    // MARK: - Tests for identificationType

    func test_identificationType_whenNetworkReturnsSuccess_shouldReturnIdentificationTypes() async {
        // Arrange
        let expectation = expectation(description: "Analytics event should be sent")
        let (sut, session, analytics) = self.makeSUT()

        await session.mock.setResponse(self.makeHTTPResponse(statusCode: 200))
        await session.mock.setData(IdentificationTypeStub.validResponse)

        // Act
        do {
            let result = try await sut.identificationTypes()

            await analytics.mock.updateSendCallback {
                expectation.fulfill()
            }

            await fulfillment(of: [expectation], timeout: 1.0)
            let messages = await analytics.mock.getMessages()

            // Assert
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result, IdentificationTypeStub.expectedTypes)
            XCTAssertEqual(
                messages,
                [
                    .track(path: "/sdk-native/core-methods/identification_types"),
                    .send
                ]
            )
        } catch {
            XCTFail("Should not throw error: \(error)")
        }
    }

    func test_identificationType_whenNetworkReturnsFormattedError_shouldCallAnalytics() async {
        // Arrange
        let expectation = expectation(description: "Analytics event should be sent")
        let (sut, session, analytics) = self.makeSUT()

        await session.mock.setResponse(self.makeHTTPResponse(statusCode: 400))
        await session.mock.setData(APIErrorStub.badRequestData)

        // Act & Assert
        try await self.assertThrowsAPIError(
            await sut.identificationTypes(),
            expectedError: APIErrorStub.badRequest
        )

        await analytics.mock.updateSendCallback {
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)
        let messages = await analytics.mock.getMessages()

        XCTAssertEqual(
            messages,
            [
                .track(path: "/sdk-native/core-methods/identification_types/error"),
                .setError("\(APIClientError.apiError(APIErrorStub.badRequest))"),
                .send
            ]
        )
    }
}
