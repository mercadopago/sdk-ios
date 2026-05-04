//
//  FetchCardPaymentBrickCardUseCaseTests.swift
//  MercadoPagoSDK
//

@testable import CoreMethods
@testable import MercadoPagoCheckout
@testable import MPCore
import XCTest

final class FetchCardPaymentBrickCardUseCaseTests: XCTestCase {
    // MARK: - Types

    typealias SUT = (
        useCase: FetchCardPaymentBrickCardUseCase,
        repository: MockCardPaymentBrickCardRepository
    )

    // MARK: - Helpers

    private func makeSUT() -> SUT {
        let repository = MockCardPaymentBrickCardRepository()
        let useCase = FetchCardPaymentBrickCardUseCase(repository: repository)
        return (useCase, repository)
    }

    private func makeParams() -> CardPaymentBrickCardParams {
        CardPaymentBrickCardParams(
            bin: "411111",
            amount: 100.0,
            checkoutType: "card_payment_brick",
            processingMode: "aggregator",
            allowCardTypes: [],
            allowCardBrands: []
        )
    }

    private func makeCardData(paymentMethods: [CardPaymentBrickCardData.PaymentMethod] = [makePaymentMethod()]) -> CardPaymentBrickCardData {
        CardPaymentBrickCardData(securityCodeTranslations: nil, installment: nil, paymentMethods: paymentMethods)
    }

    private static func makePaymentMethod(id: String = "visa") -> CardPaymentBrickCardData.PaymentMethod {
        let length = CardPaymentBrickCardData.PaymentMethod.CardNumberInfo.Length(min: 13, max: 16)
        let cardNumber = CardPaymentBrickCardData.PaymentMethod.CardNumberInfo(
            type: "credit_card",
            length: length,
            mask: "#### #### #### ####"
        )
        return CardPaymentBrickCardData.PaymentMethod(
            id: id,
            paymentTypeId: "credit_card",
            cardNumber: cardNumber,
            securityCode: nil,
            issuers: []
        )
    }

    private func makeAPIError(errorCode: String, userMessage: String = "Error message") -> APIClientError {
        .apiError(APIErrorResponse(code: "400", message: "error", errorCode: errorCode, userErrorMessage: userMessage))
    }

    // MARK: - Success

    func test_execute_whenRepositoryReturnsData_shouldReturnData() async throws {
        // Arrange
        let sut = self.makeSUT()
        let expected = self.makeCardData()
        await sut.repository.setResult(.success(expected))

        // Act
        let result = try await sut.useCase.execute(params: self.makeParams())

        // Assert
        XCTAssertEqual(result, expected)
    }

    // MARK: - Acceptance Errors

    func test_execute_whenPaymentMethodsEmpty_shouldThrowPaymentMethodNotFound() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(self.makeCardData(paymentMethods: [])))

        // Act & Assert
        do {
            _ = try await sut.useCase.execute(params: self.makeParams())
            XCTFail("Expected BinFetchError to be thrown")
        } catch {
            guard case let .acceptance(acceptance) = error,
                  case .paymentMethodNotFound = acceptance else {
                XCTFail("Expected .acceptance(.paymentMethodNotFound), got \(error)")
                return
            }
        }
    }

    func test_execute_whenAPIErrorPaymentMethodUnavailable_shouldThrowAcceptanceError() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.repository.setResult(.failure(self.makeAPIError(errorCode: "PAYMENT_METHOD_UNAVAILABLE", userMessage: "Method unavailable")))

        // Act & Assert
        do {
            _ = try await sut.useCase.execute(params: self.makeParams())
            XCTFail("Expected BinFetchError to be thrown")
        } catch {
            guard case let .acceptance(acceptance) = error,
                  case let .paymentMethodNotAllowed(message) = acceptance else {
                XCTFail("Expected .acceptance(.paymentMethodNotAllowed), got \(error)")
                return
            }
            XCTAssertEqual(message, "Method unavailable")
        }
    }

    func test_execute_whenAPIErrorUnsupportedPaymentType_shouldThrowAcceptanceError() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.repository.setResult(.failure(self.makeAPIError(errorCode: "UNSUPPORTED_PAYMENT_TYPE", userMessage: "Type not supported")))

        // Act & Assert
        do {
            _ = try await sut.useCase.execute(params: self.makeParams())
            XCTFail("Expected BinFetchError to be thrown")
        } catch {
            guard case let .acceptance(acceptance) = error,
                  case let .paymentTypeNotAllowed(message) = acceptance else {
                XCTFail("Expected .acceptance(.paymentTypeNotAllowed), got \(error)")
                return
            }
            XCTAssertEqual(message, "Type not supported")
        }
    }

    // MARK: - Network Errors

    func test_execute_whenAPIErrorUnknownCode_shouldThrowNetworkError() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.repository.setResult(.failure(self.makeAPIError(errorCode: "UNKNOWN_CODE")))

        // Act & Assert
        do {
            _ = try await sut.useCase.execute(params: self.makeParams())
            XCTFail("Expected BinFetchError to be thrown")
        } catch {
            guard case let .network(checkoutError) = error else {
                XCTFail("Expected .network, got \(error)")
                return
            }
            XCTAssertEqual(checkoutError.code, .serviceError)
        }
    }

    func test_execute_whenAPIClientErrorNonApiError_shouldThrowNetworkError() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.repository.setResult(.failure(APIClientError.networkError(URLError(.notConnectedToInternet))))

        // Act & Assert
        do {
            _ = try await sut.useCase.execute(params: self.makeParams())
            XCTFail("Expected BinFetchError to be thrown")
        } catch {
            guard case let .network(checkoutError) = error else {
                XCTFail("Expected .network, got \(error)")
                return
            }
            XCTAssertEqual(checkoutError.code, .networkConnectionFailed)
        }
    }

    func test_execute_whenMercadoPagoCheckoutError_shouldPropagateAsNetworkError() async {
        // Arrange
        let sut = self.makeSUT()
        let original = MercadoPagoCheckoutError(code: .serviceError, localizedDescription: "service error", location: .binChange)
        await sut.repository.setResult(.failure(original))

        // Act & Assert
        do {
            _ = try await sut.useCase.execute(params: self.makeParams())
            XCTFail("Expected BinFetchError to be thrown")
        } catch {
            guard case let .network(checkoutError) = error else {
                XCTFail("Expected .network, got \(error)")
                return
            }
            XCTAssertEqual(checkoutError, original)
        }
    }

    func test_execute_whenUnknownError_shouldThrowNetworkUnknown() async {
        // Arrange
        let sut = self.makeSUT()
        struct UnknownError: Error {}
        await sut.repository.setResult(.failure(UnknownError()))

        // Act & Assert
        do {
            _ = try await sut.useCase.execute(params: self.makeParams())
            XCTFail("Expected BinFetchError to be thrown")
        } catch {
            guard case let .network(checkoutError) = error else {
                XCTFail("Expected .network, got \(error)")
                return
            }
            XCTAssertEqual(checkoutError.code, .unknown)
        }
    }
}
