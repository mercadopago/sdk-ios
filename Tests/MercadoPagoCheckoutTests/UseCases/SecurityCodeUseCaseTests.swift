//
//  SecurityCodeUseCaseTests.swift
//  MercadoPagoSDK
//

@testable import CoreMethods
@testable import MercadoPagoCheckout
import XCTest

final class SecurityCodeUseCaseTests: XCTestCase {
    // MARK: - Types

    typealias SUT = (useCase: SecurityCodeUseCase, service: MockCheckoutService)

    // MARK: - Helpers

    private func makeSUT() -> SUT {
        let service = MockCheckoutService()
        let useCase = SecurityCodeUseCase(service: service)
        return (useCase, service)
    }

    private enum CardTokenStub {
        static let valid = CardToken(
            token: "test_token_12345",
            publicKey: nil,
            bin: nil,
            expirationMonth: nil,
            expirationYear: nil,
            lastFourDigits: nil,
            cardHolder: nil,
            status: nil,
            dateCreated: nil,
            dateLastUpdated: nil,
            dateDue: nil,
            luhnValidation: nil,
            liveMode: nil,
            requireEsc: nil,
            cardNumberLength: nil,
            securityCodeLength: nil,
            truncCardNumber: nil
        )
    }

    // MARK: - executeWithoutSecurityCode(cardId:)

    func test_executeWithoutSecurityCode_sendsCardIdWithEmptySecurityCodeAndCardNumber() async throws {
        let sut = self.makeSUT()
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))

        _ = try await sut.useCase.executeWithoutSecurityCode(cardId: "card_123")

        let capturedParams = await sut.service.capturedCardParams
        XCTAssertEqual(capturedParams?.cardId, "card_123")
        XCTAssertEqual(capturedParams?.cardNumber, "")
        XCTAssertEqual(capturedParams?.securityCode, "")
    }

    func test_executeWithoutSecurityCode_onSuccess_returnsToken() async throws {
        let sut = self.makeSUT()
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))

        let token = try await sut.useCase.executeWithoutSecurityCode(cardId: "card_123")

        XCTAssertEqual(token.token, CardTokenStub.valid.token)
    }

    func test_executeWithoutSecurityCode_onFailure_throwsError() async {
        let sut = self.makeSUT()
        let expectedError = MercadoPagoCheckoutError(code: .serviceError, localizedDescription: "failed", location: .tokenization)
        await sut.service.setCreateCardTokenResult(.failure(expectedError))

        do {
            _ = try await sut.useCase.executeWithoutSecurityCode(cardId: "card_123")
            XCTFail("Should not throw error")
        } catch {
            XCTAssertEqual(error.code, expectedError.code)
        }
    }
}
