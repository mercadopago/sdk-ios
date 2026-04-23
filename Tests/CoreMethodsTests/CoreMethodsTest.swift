import CommonTests
@testable import CoreMethods
import MPCore
import Testing
import XCTest

// MARK: - CoreMethodsTests

@MainActor
final class CoreMethodsTests: XCTestCase {
    // MARK: - Types

    typealias SUT = (
        coreMethodsService: CoreMethods,
        repository: MockCoreMethodsRepository,
        analytics: MockAnalytics
    )

    // MARK: - Stubs and Factories

    /// Identification type response model
    private enum IdentificationTypeStub {
        static let validDNI = IdentificationType(
            id: "DNI",
            name: "DNI",
            type: "number",
            minLength: 7,
            maxLength: 8
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

        static var responseModels: [IdentificationTypesResponse] {
            [
                .init(
                    id: "DNI",
                    name: "DNI",
                    type: "number",
                    minLength: 7,
                    maxLength: 8
                )
            ]
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
                            id: 1,
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

    private enum IssuerStub {
        static var expectResponse: [Issuer] {
            [
                .init(
                    id: "0",
                    name: "Banco",
                    merchantAccountId: "",
                    processingMode: "aggregator",
                    status: "active",
                    thumbnail: ""
                )
            ]
        }

        static var validResponse: Data {
            let response = """
            [
                {
                    "id": "0",
                    "name": "Banco",
                    "merchant_account_id": "",
                    "processing_mode": "aggregator",
                    "status": "active",
                    "thumbnail": ""
                }
            ]
            """
            return Data(response.utf8)
        }
    }

    /// API error response model
    private enum APIErrorStub {
        static let badRequest = APIErrorResponse(code: "400", errorCode: nil, message: "Bad Request")

        static var badRequestData: Data {
            try! JSONEncoder().encode(badRequest)
        }
    }

    // MARK: - Card Fields Factory

    @MainActor
    private func makeCardFields() async -> (
        cardNumber: CardNumberTextField,
        expirationDate: ExpirationDateTextfield,
        securityCode: SecurityCodeTextField
    ) {
        let container = MockDependencyContainer()
        let cardNumberField = CardNumberTextField(dependencies: container)
        let expirationDateField = ExpirationDateTextfield(dependencies: container)
        let securityCodeField = SecurityCodeTextField(dependencies: container)

        cardNumberField.input.textField.text = "12345678"
        expirationDateField.setFormat(.long)
        expirationDateField.input.textField.text = "12/2032"
        securityCodeField.input.textField.text = "123"

        return (cardNumberField, expirationDateField, securityCodeField)
    }

    // MARK: - Setup SUT

    private func makeSUT(file _: StaticString = #filePath, line _: UInt = #line) async -> SUT {
        let container = MockDependencyContainer()
        let analytics = container.mockAnalytics
        let repository = MockCoreMethodsRepository()

        let repositoryThreeDS = MockThreeDSRepository()

        let paymentMethodUseCase = PaymentMethodUseCase(repository: repository)
        let generateTokenUseCase = GenerateCardTokenUseCase(
            dependencies: container,
            repository: repository,
            paymentMethodUseCase: paymentMethodUseCase
        )
        let identificationTypeUseCase = IdentificationTypesUseCase(repository: repository)
        let installmentsUseCase: InstallmentsUseCaseProtocol = InstallmentsUseCase(repository: repository)
        let issuerUseCase = IssuerUseCase(repository: repository)
        let capabilityUseCase = CapabilityUseCase(repository: repositoryThreeDS)

        let coreMethodsService = CoreMethods(
            dependencies: container,
            generateTokenUseCase: generateTokenUseCase,
            identificationTypeUseCase: identificationTypeUseCase,
            installmentsUseCase: installmentsUseCase,
            paymentMethodUseCase: paymentMethodUseCase,
            issuerUseCase: issuerUseCase,
            capabilityUseCase: capabilityUseCase
        )

        return (coreMethodsService, repository, analytics)
    }

    // MARK: - Error assertion helpers

    private func assertThrowsAPIError(
        _ expression: @autoclosure () async throws -> Any,
        expectedError: APIErrorResponse,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            _ = try await expression()
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
        let (sut, repository, _) = await self.makeSUT()
        let (cardNumber, expirationDate, securityCode) = await makeCardFields()

        await repository.setPaymentMethodsResult(.success(PaymentMethodStub.expectedResponse))
        await repository.setGenerateCardTokenResult(.success(CardTokenStub.responseModel))

        // Act
        do {
            let result = try await sut.createToken(
                cardNumber: cardNumber,
                expirationDate: expirationDate,
                securityCode: securityCode,
                cardHolderName: ""
            )

            // Assert
            XCTAssertEqual(result, CardTokenStub.expectedToken)
        } catch {
            XCTFail("Should not throw error: \(error)")
        }
    }

    func test_createToken_whenNetworkReturnsError_shouldThrowDecodingError() async {
        // Arrange
        let (sut, repository, _) = await self.makeSUT()
        let (cardNumber, expirationDate, securityCode) = await makeCardFields()
        await repository.setPaymentMethodsResult(.success(PaymentMethodStub.expectedResponse))

        await repository.setGenerateCardTokenResult(
            .failure(APIClientError.decodingFailed(NSError(domain: "test", code: 0)))
        )

        // Act & Assert
        do {
            _ = try await sut.createToken(
                cardNumber: cardNumber,
                expirationDate: expirationDate,
                securityCode: securityCode,
                cardHolderName: ""
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
        let (sut, repository, _) = await self.makeSUT()
        let (cardNumber, expirationDate, securityCode) = await makeCardFields()
        await repository.setPaymentMethodsResult(.success(PaymentMethodStub.expectedResponse))

        await repository.setGenerateCardTokenResult(.failure(APIClientError.apiError(APIErrorStub.badRequest)))

        // Act & Assert
        try await self.assertThrowsAPIError(
            await sut.createToken(
                cardNumber: cardNumber,
                expirationDate: expirationDate,
                securityCode: securityCode,
                cardHolderName: ""
            ),
            expectedError: APIErrorStub.badRequest
        )
    }

    func test_createToken_whenExpirationDateEmpty_shouldThrowExpirationDateInvalid() async {
        // Arrange
        let (sut, _, _) = await self.makeSUT()
        let (cardNumber, expirationDate, securityCode) = await makeCardFields()
        expirationDate.input.textField.text = ""

        // Act & Assert
        do {
            _ = try await sut.createToken(
                cardNumber: cardNumber,
                expirationDate: expirationDate,
                securityCode: securityCode,
                cardHolderName: ""
            )
            XCTFail("Expected CoreMethodsError.expirationDateInvalid error")
        } catch let error as CoreMethodsError {
            guard case .expirationDateInvalid = error else {
                XCTFail("Expected CoreMethodsError.expirationDateInvalid error but got \(error)")
                return
            }
        } catch {
            XCTFail("Expected CoreMethodsError.expirationDateInvalid error but got \(error)")
        }
    }

    func test_createToken_whenCardNumberEmpty_shouldThrowCardNumberInvalid() async {
        // Arrange
        let (sut, _, _) = await self.makeSUT()
        let (cardNumber, expirationDate, securityCode) = await makeCardFields()
        cardNumber.input.textField.text = ""

        // Act & Assert
        do {
            _ = try await sut.createToken(
                cardNumber: cardNumber,
                expirationDate: expirationDate,
                securityCode: securityCode,
                cardHolderName: ""
            )
            XCTFail("Expected CoreMethodsError.cardNumberInvalid error")
        } catch let error as CoreMethodsError {
            guard case .cardNumberInvalid = error else {
                XCTFail("Expected CoreMethodsError.cardNumberInvalid error but got \(error)")
                return
            }
        } catch {
            XCTFail("Expected CoreMethodsError.cardNumberInvalid error but got \(error)")
        }
    }

    func test_createToken_whenSecurityCodeEmpty_shouldThrowSecurityCodeInvalid() async {
        // Arrange
        let (sut, repository, _) = await self.makeSUT()
        let (cardNumber, expirationDate, securityCode) = await makeCardFields()
        await repository.setPaymentMethodsResult(.success(PaymentMethodStub.expectedResponse))

        securityCode.input.textField.text = ""

        // Act & Assert
        do {
            _ = try await sut.createToken(
                cardNumber: cardNumber,
                expirationDate: expirationDate,
                securityCode: securityCode,
                cardHolderName: ""
            )
            XCTFail("Expected CoreMethodsError.securityCodeInvalid error")
        } catch let error as CoreMethodsError {
            guard case .securityCodeInvalid = error else {
                XCTFail("Expected CoreMethodsError.securityCodeInvalid error but got \(error)")
                return
            }
        } catch {
            XCTFail("Expected CoreMethodsError.securityCodeInvalid error but got \(error)")
        }
    }

    // MARK: - Tests for createToken with cardID

    func test_createToken_withValidCardID_shouldReturnCardToken() async {
        // Arrange
        let (sut, repository, _) = await self.makeSUT()
        let cardID = "123"
        let (_, _, securityCode) = await makeCardFields()

        await repository.setGenerateCardTokenResult(.success(CardTokenStub.responseModel))

        // Act
        do {
            let result = try await sut.createToken(
                cardID: cardID,
                securityCode: securityCode
            )

            // Assert
            XCTAssertEqual(result, CardTokenStub.expectedToken)
        } catch {
            XCTFail("Expected success but got \(error)")
        }
    }

    func test_createToken_withDocumentAndCardholderName_whenNetworkReturnsSuccess_shouldReturnCardToken() async {
        // Arrange
        let (sut, repository, _) = await self.makeSUT()
        let (cardNumber, expirationDate, securityCode) = await makeCardFields()
        let documentType = IdentificationTypeStub.validDNI
        let documentNumber = "12345678"
        let cardHolderName = "João Silva"

        await repository.setPaymentMethodsResult(.success(PaymentMethodStub.expectedResponse))
        await repository.setGenerateCardTokenResult(.success(CardTokenStub.responseModel))

        // Act
        do {
            let result = try await sut.createToken(
                cardNumber: cardNumber,
                expirationDate: expirationDate,
                securityCode: securityCode,
                documentType: documentType,
                documentNumber: documentNumber,
                cardHolderName: cardHolderName
            )

            // Assert
            XCTAssertEqual(result, CardTokenStub.expectedToken)
        } catch {
            XCTFail("Should not throw error: \(error)")
        }
    }

    func test_createToken_withDocumentAndCardholderName_whenNetworkReturnsError_shouldThrowAPIError() async {
        // Arrange
        let (sut, repository, _) = await self.makeSUT()
        let (cardNumber, expirationDate, securityCode) = await makeCardFields()
        let documentType = IdentificationTypeStub.validDNI
        let documentNumber = "12345678"
        let cardHolderName = "João Silva"

        await repository.setPaymentMethodsResult(.success(PaymentMethodStub.expectedResponse))
        await repository.setGenerateCardTokenResult(.failure(APIClientError.apiError(APIErrorStub.badRequest)))

        // Act & Assert
        try await self.assertThrowsAPIError(
            await sut.createToken(
                cardNumber: cardNumber,
                expirationDate: expirationDate,
                securityCode: securityCode,
                documentType: documentType,
                documentNumber: documentNumber,
                cardHolderName: cardHolderName
            ),
            expectedError: APIErrorStub.badRequest
        )
    }

    func test_createToken_withDocumentAndCardholderName_shouldSendAnalyticsEvent() async {
        // Arrange
        let (sut, repository, analytics) = await self.makeSUT()
        let (cardNumber, expirationDate, securityCode) = await makeCardFields()
        let documentType = IdentificationTypeStub.validDNI
        let documentNumber = "12345678"
        let cardHolderName = "João Silva"
        let expectEventData = TokenizationEventData(isSaveCard: false, documentType: documentType.name)

        await repository.setPaymentMethodsResult(.success(PaymentMethodStub.expectedResponse))
        await repository.setGenerateCardTokenResult(.success(CardTokenStub.responseModel))

        // Act
        do {
            _ = try await sut.createToken(
                cardNumber: cardNumber,
                expirationDate: expirationDate,
                securityCode: securityCode,
                documentType: documentType,
                documentNumber: documentNumber,
                cardHolderName: cardHolderName
            )

            await analytics.mock.waitForSend()
            let messages = await analytics.mock.getMessages()

            // Assert
            XCTAssertEqual(
                messages,
                [
                    .track(path: "/checkout_api_native/core_methods/tokenization"),
                    .setEventData(expectEventData.toDictionary()),
                    .send
                ]
            )
        } catch {
            XCTFail("Should not throw error: \(error)")
        }
    }

    // MARK: - Tests for createToken with cardID and expirationDate

    func test_createToken_withCardIDAndExpirationDate_shouldReturnCardToken() async {
        // Arrange
        let (sut, repository, _) = await self.makeSUT()
        let cardID = "123"
        let (_, expirationDate, securityCode) = await makeCardFields()

        await repository.setGenerateCardTokenResult(.success(CardTokenStub.responseModel))

        // Act
        do {
            let result = try await sut.createToken(
                cardID: cardID,
                expirationDate: expirationDate,
                securityCode: securityCode
            )

            // Assert
            XCTAssertEqual(result, CardTokenStub.expectedToken)
        } catch {
            XCTFail("Expected success but got \(error)")
        }
    }

    func test_createToken_withCardIDAndExpirationDate_whenNetworkReturnsError_shouldThrowAPIError() async {
        // Arrange
        let (sut, repository, _) = await self.makeSUT()
        let cardID = "123"
        let (_, expirationDate, securityCode) = await makeCardFields()

        await repository.setGenerateCardTokenResult(.failure(APIClientError.apiError(APIErrorStub.badRequest)))

        // Act & Assert
        try await self.assertThrowsAPIError(
            await sut.createToken(
                cardID: cardID,
                expirationDate: expirationDate,
                securityCode: securityCode
            ),
            expectedError: APIErrorStub.badRequest
        )
    }

    func test_createToken_withCardID_shouldSendAnalyticsEventWithSaveCardFlag() async {
        // Arrange
        let (sut, repository, analytics) = await self.makeSUT()
        let cardID = "123"
        let (_, _, securityCode) = await makeCardFields()
        let expectEventData = TokenizationEventData(isSaveCard: true, documentType: "")

        await repository.setGenerateCardTokenResult(.success(CardTokenStub.responseModel))

        // Act
        do {
            _ = try await sut.createToken(
                cardID: cardID,
                securityCode: securityCode
            )

            await analytics.mock.waitForSend()
            let messages = await analytics.mock.getMessages()

            // Assert
            XCTAssertEqual(
                messages,
                [
                    .track(path: "/checkout_api_native/core_methods/tokenization"),
                    .setEventData(expectEventData.toDictionary()),
                    .send
                ]
            )
        } catch {
            XCTFail("Should not throw error: \(error)")
        }
    }

    // MARK: - Tests for identificationType

    func test_identificationType_whenNetworkReturnsSuccess_shouldReturnIdentificationTypes() async {
        // Arrange
        let (sut, repository, analytics) = await self.makeSUT()

        await repository.setIdentificationTypesResult(.success(IdentificationTypeStub.responseModels))
        let docs = IdentificationTypeStub.expectedTypes.map { data in
            data.name
        }
        let expectEventData = IdentificationTypeEventData(documentTypes: docs)

        // Act
        do {
            let result = try await sut.identificationTypes()

            await analytics.mock.waitForSend()
            let messages = await analytics.mock.getMessages()

            // Assert
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result, IdentificationTypeStub.expectedTypes)
            XCTAssertEqual(
                messages,
                [
                    .track(path: "/checkout_api_native/core_methods/identification_types"),
                    .setEventData(expectEventData.toDictionary()),
                    .send
                ]
            )
        } catch {
            XCTFail("Should not throw error: \(error)")
        }
    }

    func test_identificationType_whenNetworkReturnsFormattedError_shouldCallAnalytics() async {
        // Arrange
        let (sut, repository, analytics) = await self.makeSUT()

        await repository.setIdentificationTypesResult(.failure(APIClientError.apiError(APIErrorStub.badRequest)))
        let expectEventData = IdentificationTypeEventData(documentTypes: [])

        // Act & Assert
        try await self.assertThrowsAPIError(
            await sut.identificationTypes(),
            expectedError: APIErrorStub.badRequest
        )

        await analytics.mock.waitForSend()
        let messages = await analytics.mock.getMessages()

        XCTAssertEqual(
            messages,
            [
                .track(path: "/checkout_api_native/core_methods/identification_types/error"),
                .setError("\(APIClientError.apiError(APIErrorStub.badRequest))"),
                .setEventData(expectEventData.toDictionary()),
                .send
            ]
        )
    }

    func test_installments_whenNetworkReturnsSuccess_shouldReturnInstallment() async {
        // Arrange
        let (sut, repository, analytics) = await self.makeSUT()
        let expectResponse = InstallmentsStub.expectResponse
        let expectEventData = InstallmentEventData(
            amount: 5000,
            paymentType: expectResponse[0].paymentTypeId
        )

        await repository.setInstallmentsResult(.success(InstallmentsStub.expectResponse))

        // Act
        do {
            let result = try await sut.installments(amount: 5000, bin: "12345678")

            await analytics.mock.waitForSend()
            let messages = await analytics.mock.getMessages()

            // Assert
            XCTAssertEqual(result, InstallmentsStub.expectResponse)

            XCTAssertEqual(
                messages,
                [
                    .track(path: "/checkout_api_native/core_methods/installments"),
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
        let (sut, repository, analytics) = await self.makeSUT()
        let expectEventData = InstallmentEventData(
            amount: 500,
            paymentType: ""
        )

        await repository.setInstallmentsResult(.failure(APIClientError.apiError(APIErrorStub.badRequest)))

        // Act & Assert
        try await self.assertThrowsAPIError(
            await sut.installments(amount: 500, bin: "1234"),
            expectedError: APIErrorStub.badRequest
        )

        await analytics.mock.waitForSend()
        let messages = await analytics.mock.getMessages()

        XCTAssertEqual(
            messages,
            [
                .track(path: "/checkout_api_native/core_methods/installments/error"),
                .setError("\(APIClientError.apiError(APIErrorStub.badRequest))"),
                .setEventData(expectEventData.toDictionary()),
                .send
            ]
        )
    }

    func test_paymentMethods_whenNetworkReturnsSuccess_shouldReturnPaymentMethodsAndSendEventData() async {
        // Arrange
        let (sut, repository, analytics) = await self.makeSUT()

        let data = PaymentMethodStub.expectedResponse[0]
        let expectEventData = PaymentMethodEventData(
            issuer: data.issuer?.id,
            paymentType: data.paymentTypeId,
            sizeSecurityCode: data.card?.securityCode.length,
            cardBrand: data.id
        )

        await repository.setPaymentMethodsResult(.success(PaymentMethodStub.expectedResponse))

        // Act
        do {
            let result = try await sut.paymentMethods(bin: "502432")

            await analytics.mock.waitForSend()
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
                    .track(path: "/checkout_api_native/core_methods/payment_methods"),
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
        let (sut, repository, analytics) = await self.makeSUT()
        let expectEventData = PaymentMethodEventData()

        await repository.setPaymentMethodsResult(.failure(APIClientError.apiError(APIErrorStub.badRequest)))

        // Act & Assert
        try await self.assertThrowsAPIError(
            await sut.paymentMethods(bin: "502432"),
            expectedError: APIErrorStub.badRequest
        )

        await analytics.mock.waitForSend()
        let messages = await analytics.mock.getMessages()

        XCTAssertEqual(
            messages,
            [
                .track(path: "/checkout_api_native/core_methods/payment_methods/error"),
                .setError("\(APIClientError.apiError(APIErrorStub.badRequest))"),
                .setEventData(expectEventData.toDictionary()),
                .send
            ]
        )
    }

    func test_paymentMethods_whenEmptyArrayReturned_shouldNotSendEventData() async {
        // Arrange
        let (sut, repository, analytics) = await self.makeSUT()
        let expectEventData = PaymentMethodEventData(
            issuer: nil,
            paymentType: nil,
            sizeSecurityCode: nil,
            cardBrand: nil
        )

        await repository.setPaymentMethodsResult(.success([]))

        // Act
        do {
            let result = try await sut.paymentMethods(bin: "502432")

            await analytics.mock.waitForSend()
            let messages = await analytics.mock.getMessages()

            // Assert
            XCTAssertTrue(result.isEmpty)

            XCTAssertEqual(
                messages,
                [
                    .track(path: "/checkout_api_native/core_methods/payment_methods"),
                    .setEventData(expectEventData.toDictionary()),
                    .send
                ]
            )
        } catch {
            XCTFail("Should not throw error: \(error)")
        }
    }

    func test_issuer_whenNetworkReturnsSuccess_shouldReturnInstallment() async {
        // Arrange
        let (sut, repository, analytics) = await self.makeSUT()
        let expectResponse = IssuerStub.expectResponse
        let expectEventData = IssuersEventData(issuers: ["Banco"])

        await repository.setIssuersResult(.success(IssuerStub.expectResponse))

        // Act
        do {
            let result = try await sut.issuers(bin: "300", paymentMethodID: "12345")

            await analytics.mock.waitForSend()
            let messages = await analytics.mock.getMessages()

            // Assert
            XCTAssertEqual(result, expectResponse)

            XCTAssertEqual(
                messages,
                [
                    .track(path: "/checkout_api_native/core_methods/issuers"),
                    .setEventData(expectEventData.toDictionary()),
                    .send
                ]
            )
        } catch {
            XCTFail("Should not throw error: \(error)")
        }
    }

    func test_issuer_whenNetworkReturnsFormattedError_shouldCallAnalytics() async {
        // Arrange
        let (sut, repository, analytics) = await self.makeSUT()
        let expectEventData = IssuersEventData(issuers: [])

        await repository.setIssuersResult(.failure(APIClientError.apiError(APIErrorStub.badRequest)))

        // Act & Assert
        try await self.assertThrowsAPIError(
            await sut.issuers(bin: "000", paymentMethodID: "master"),
            expectedError: APIErrorStub.badRequest
        )

        await analytics.mock.waitForSend()
        let messages = await analytics.mock.getMessages()

        XCTAssertEqual(
            messages,
            [
                .track(path: "/checkout_api_native/core_methods/issuers/error"),
                .setError("\(APIClientError.apiError(APIErrorStub.badRequest))"),
                .setEventData(expectEventData.toDictionary()),
                .send
            ]
        )
    }
}
