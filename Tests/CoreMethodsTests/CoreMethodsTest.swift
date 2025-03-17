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

    /// Identification type response model
    private enum InstallmentsStub {
        static var expectResponse: [Installment] {
            [
                .init(
                    paymentMethodId: "master",
                    paymentTypeId: "credit_card",
                    thumbnail: "www.google.com",
                    issuer: Installment.Issuer(id: "1", thumbnail: "www.google.com"),
                    processingMode: "aggregator",
                    merchantAccountId: "",
                    payerCosts: [
                        Installment.PayerCost(
                            installments: 1,
                            installmentAmount: 5000,
                            installmentRate: 0,
                            installmentRateCollector: ["MP"],
                            totalAmount: 5000,
                            minAllowedAmount: 0.5,
                            maxAllowedAmount: 60000,
                            discountRate: 0,
                            reimbursementRate: 0,
                            labels: [],
                            paymentMethodOptionId: "000000"
                        )
                    ],
                    agreements: []
                )
            ]
        }

        static var validResponse: Data {
            let response = """
            [
                {
                  "payment_method_id": "master",
                  "payment_type_id": "credit_card",
                  "thumbnail": "www.google.com",
                  "issuer": {
                    "id": "1",
                    "thumbnail": "www.google.com"
                  },
                  "processing_mode": "aggregator",
                  "merchant_account_id": "",
                  "payer_costs": [
                    {
                      "installments": 1,
                      "installment_amount": 5000,
                      "installment_rate": 0,
                      "installment_rate_collector": [
                        "MP"
                      ],
                      "total_amount": 5000,
                      "min_allowed_amount": 0.5,
                      "max_allowed_amount": 60000,
                      "discount_rate": 0,
                      "reimbursement_rate": 0,
                      "labels": [],
                      "payment_method_option_id": "000000"
                    }
                  ],
                  "agreements": []
                }
            ]
            """
            return Data(response.utf8)
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
        let container = MockDependencyContainer()
        let cardNumberField = await CardNumberTextField(dependencies: container)
        let expirationDateField = await ExpirationDateTextfield(dependencies: container)
        let securityCodeField = await SecurityCodeTextField(dependencies: container)

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
        let installmentsUseCase: InstallmentsUseCaseProtocol = InstallmentsUseCase(repository: repository)
        let paymentMethodUseCase = PaymentMethodUseCase(repository: repository)

        let coreMethodsService = CoreMethods(
            dependencies: container,
            generateTokenUseCase: generateTokenUseCase,
            identificationTypeUseCase: identificationTypeUseCase,
            installmentsUseCase: installmentsUseCase,
            paymentMethodUseCase: paymentMethodUseCase
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
        let (_, _, securityCode) = await makeCardFields()

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

    func test_installments_whenNetworkReturnsSuccess_shouldReturnInstallment() async {
        // Arrange
        let (sut, session, analytics) = self.makeSUT()
        let expectation = expectation(description: "Analytics event should be sent")
        let expectResponse = InstallmentsStub.expectResponse
        let expectEventData = InstallmentEventData(
            amount: 5000,
            paymentType: expectResponse[0].paymentTypeId
        )

        await session.mock.setResponse(self.makeHTTPResponse(statusCode: 200))
        await session.mock.setData(InstallmentsStub.validResponse)

        // Act
        do {
            let result = try await sut.installments(amount: 5000, bin: "12345678")

            await analytics.mock.updateSendCallback {
                expectation.fulfill()
            }

            await fulfillment(of: [expectation], timeout: 1.0)
            let messages = await analytics.mock.getMessages()

            // Assert
            XCTAssertEqual(result, InstallmentsStub.expectResponse)

            XCTAssertEqual(
                messages,
                [
                    .track(path: "/sdk-native/core-methods/installments"),
                    .setEventData(expectEventData.toDictionary()),
                    .send
                ]
            )
        } catch {
            XCTFail("Should not throw error: \(error)")
        }
    }

    func test_installment_whenNetworkReturnsFormattedError_shouldCallAnalytics() async {
        // Arrange
        let expectation = expectation(description: "Analytics event should be sent")
        let (sut, session, analytics) = self.makeSUT()

        await session.mock.setResponse(self.makeHTTPResponse(statusCode: 400))
        await session.mock.setData(APIErrorStub.badRequestData)

        // Act & Assert
        try await self.assertThrowsAPIError(
            await sut.installments(amount: 500, bin: "1234"),
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
                .track(path: "/sdk-native/core-methods/installments/error"),
                .setError("\(APIClientError.apiError(APIErrorStub.badRequest))"),
                .send
            ]
        )
    }

    func test_paymentMethods_whenNetworkReturnsSuccess_shouldReturnPaymentMethodsAndSendEventData() async {
        // Arrange
        let expectation = expectation(description: "Analytics event should be sent")
        let (sut, session, analytics) = self.makeSUT()

        let data = PaymentMethodStub.expectedResponse[0]
        let expectEventData = PaymentMethodEventData(
            issuer: data.issuer?.id,
            paymentType: data.paymentTypeId,
            sizeSecurityCode: data.card?.securityCode.length,
            cardBrand: data.id
        )

        await session.mock.setResponse(self.makeHTTPResponse(statusCode: 200))
        await session.mock.setData(PaymentMethodStub.validResponse)

        // Act
        do {
            let result = try await sut.paymentMethods(bin: "502432")

            await analytics.mock.updateSendCallback {
                expectation.fulfill()
            }

            await fulfillment(of: [expectation], timeout: 1.0)
            let messages = await analytics.mock.getMessages()

            // Assert
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result[0].id, "master")
            XCTAssertEqual(result[0].paymentTypeId, "credit_card")
            XCTAssertEqual(result[0].issuer?.id, 24)
            XCTAssertEqual(result[0].card?.securityCode.length, 3)

            XCTAssertEqual(
                messages,
                [
                    .track(path: "/sdk-native/core-methods/payment_methods"),
                    .setEventData(expectEventData.toDictionary()),
                    .send
                ]
            )
        } catch {
            XCTFail("Should not throw error: \(error)")
        }
    }

    func test_paymentMethods_whenNetworkReturnsFormattedError_shouldCallAnalyticsWithError() async {
        // Arrange
        let expectation = expectation(description: "Analytics error event should be sent")
        let (sut, session, analytics) = self.makeSUT()

        await session.mock.setResponse(self.makeHTTPResponse(statusCode: 400))
        await session.mock.setData(APIErrorStub.badRequestData)

        // Act & Assert
        try await self.assertThrowsAPIError(
            await sut.paymentMethods(bin: "502432"),
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
                .track(path: "/sdk-native/core-methods/payment_methods/error"),
                .setError("\(APIClientError.apiError(APIErrorStub.badRequest))"),
                .send
            ]
        )
    }

    func test_paymentMethods_whenEmptyArrayReturned_shouldNotSendEventData() async {
        // Arrange
        let expectation = expectation(description: "Analytics event should be sent")
        let (sut, session, analytics) = self.makeSUT()
        let expectEventData = PaymentMethodEventData(
            issuer: nil,
            paymentType: nil,
            sizeSecurityCode: nil,
            cardBrand: nil
        )

        await session.mock.setResponse(self.makeHTTPResponse(statusCode: 200))
        await session.mock.setData("[]".data(using: .utf8)!)

        // Act
        do {
            let result = try await sut.paymentMethods(bin: "502432")

            await analytics.mock.updateSendCallback {
                expectation.fulfill()
            }

            await fulfillment(of: [expectation], timeout: 1.0)
            let messages = await analytics.mock.getMessages()

            // Assert
            XCTAssertTrue(result.isEmpty)

            XCTAssertEqual(
                messages,
                [
                    .track(path: "/sdk-native/core-methods/payment_methods"),
                    .setEventData(expectEventData.toDictionary()),
                    .send
                ]
            )
        } catch {
            XCTFail("Should not throw error: \(error)")
        }
    }
}
