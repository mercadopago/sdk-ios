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
        session: MockURLSession,
        paymentMethodUseCase: PaymentMethodUseCaseMock
    )

    func makeSUT(file _: StaticString = #filePath, line _: UInt = #line) -> SUT {
        let container = MockDependencyContainer()
        let session = container.mockSession
        let repository = CoreMethodsRepository(dependencies: container)
        let paymentMethodUseCase = PaymentMethodUseCaseMock(result: [paymentMethodStub()])

        let sut = GenerateCardTokenUseCase(
            dependencies: container,
            repository: repository,
            paymentMethodUseCase: paymentMethodUseCase
        )

        return (sut, session, paymentMethodUseCase)
    }

    private func makeSuccessResponse(url: URL = URL(string: "http://example.com")!) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
}

final class GenerateCardTokenUseCaseTests: XCTestCase {
    func test_tokenize_WhenNetworkReturnSucessful_ShouldReturnCardToken() async {
        let (sut, session, _) = self.makeSUT()

        let data = CardTokenStub.validResponse
        let expectedToken = CardTokenStub.expectedToken

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

            XCTAssertEqual(result, expectedToken)

        } catch {
            XCTFail("Should not throw error")
        }
    }
}

// MARK: - Helpers

private extension GenerateCardTokenUseCaseTests {
    final class PaymentMethodUseCaseMock: PaymentMethodUseCaseProtocol, Sendable {
        let result: [PaymentMethod]

        init(result: [PaymentMethod]) {
            self.result = result
        }

        func getPaymentMethods(params _: PaymentMethodsParams) async throws -> [PaymentMethod] {
            return self.result
        }
    }

    func paymentMethodStub() -> PaymentMethod {
        PaymentMethod(
            id: "visa",
            paymentTypeId: "credit_card",
            status: "active",
            processingMode: "aggregator",
            accreditationTime: 0,
            merchantAccountId: "",
            siteId: "MLA",
            thumbnail: nil,
            minAccreditationDays: 0,
            maxAccreditationDays: 0,
            totalFinancialCost: 0,
            financialInstitution: nil,
            issuer: nil,
            card: .init(
                bin: 502_432,
                length: .init(min: 16, max: 16),
                validation: "standard",
                securityCode: .init(
                    mode: "mandatory",
                    location: "back",
                    length: 3
                )
            ),
            bins: nil,
            marketplace: nil,
            deferredCapture: nil,
            agreements: nil,
            payerCosts: nil,
            labels: nil,
            additionalInfoNeeded: nil
        )
    }
}
