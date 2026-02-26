//
//  FetchBinDataUseCaseTests.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 26/02/26.
//

import XCTest
@testable import MercadoPagoCheckout
@testable import CoreMethods

final class FetchBinDataUseCaseTests: XCTestCase {

    // MARK: - Types

    typealias SUT = (
        useCase: FetchBinDataUseCase,
        service: MockBinFetchingService
    )

    // MARK: - Stubs

    private enum PaymentMethodStub {
        static let visa = makePaymentMethod(id: "visa", paymentTypeId: "credit_card")
        static let master = makePaymentMethod(id: "master", paymentTypeId: "credit_card")
        static let debitVisa = makePaymentMethod(id: "debvisa", paymentTypeId: "debit_card")
        static let visaWithIssuer = makePaymentMethod(id: "visa", paymentTypeId: "credit_card", additionalInfoNeeded: ["issuer_id"])

        private static func makePaymentMethod(
            id: String,
            paymentTypeId: String,
            additionalInfoNeeded: [String]? = nil
        ) -> PaymentMethod {
            PaymentMethod(
                id: id,
                paymentTypeId: paymentTypeId,
                status: "active",
                processingMode: "aggregator",
                accreditationTime: 0,
                merchantAccountId: "",
                siteId: "MLB",
                thumbnail: nil,
                minAccreditationDays: 0,
                maxAccreditationDays: 0,
                totalFinancialCost: 0,
                financialInstitution: nil,
                issuer: nil,
                card: nil,
                bins: nil,
                marketplace: nil,
                deferredCapture: nil,
                agreements: nil,
                payerCosts: nil,
                labels: nil,
                additionalInfoNeeded: additionalInfoNeeded
            )
        }
    }

    private enum IssuerStub {
        static let santander = Issuer(id: "1111", name: "Santander", merchantAccountId: "", processingMode: "", status: "active", thumbnail: "")
        static let bradesco = Issuer(id: "2222", name: "Bradesco", merchantAccountId: "", processingMode: "", status: "active", thumbnail: "")
    }

    private enum InstallmentStub {
        static func make(issuerId: String) -> Installment {
            Installment(
                paymentMethodId: "visa",
                paymentTypeId: "credit_card",
                thumbnail: "",
                issuer: Installment.Issuer(id: issuerId, thumbnail: ""),
                processingMode: "aggregator",
                merchantAccountId: "",
                payerCosts: [],
                agreements: []
            )
        }

        static let withSantander = make(issuerId: IssuerStub.santander.id)
        static let withBradesco = make(issuerId: IssuerStub.bradesco.id)
    }

    // MARK: - Helpers

    private func makeSUT() -> SUT {
        let service = MockBinFetchingService()
        let useCase = FetchBinDataUseCase(service: service)
        return (useCase, service)
    }

    private func execute(
        _ useCase: FetchBinDataUseCase,
        bin: String = "12345678",
        amount: Double? = nil,
        acceptedPaymentTypeIds: [String] = ["credit_card"],
        acceptedPaymentMethodIds: [String] = []
    ) async throws -> CardBinData {
        try await useCase.execute(
            bin: bin,
            amount: amount,
            acceptedPaymentTypeIds: acceptedPaymentTypeIds,
            acceptedPaymentMethodIds: acceptedPaymentMethodIds
        )
    }

    // MARK: - Payment Method Not Found

    func test_execute_whenPaymentMethodsIsEmpty_shouldThrow() async {
        // Arrange
        let sut = makeSUT()
        await sut.service.setPaymentMethodResult(.success([]))

        // Act / Assert
        await XCTAssertThrowsErrorAsync(try await execute(sut.useCase))
    }

    func test_execute_whenNoMatchingPaymentType_shouldThrow() async {
        // Arrange
        let sut = makeSUT()
        await sut.service.setPaymentMethodResult(.success([PaymentMethodStub.debitVisa]))

        // Act / Assert
        await XCTAssertThrowsErrorAsync(
            try await execute(sut.useCase, acceptedPaymentTypeIds: ["credit_card"])
        )
    }

    func test_execute_whenNoMatchingPaymentMethodId_shouldThrow() async {
        // Arrange
        let sut = makeSUT()
        await sut.service.setPaymentMethodResult(.success([PaymentMethodStub.visa]))

        // Act / Assert
        await XCTAssertThrowsErrorAsync(
            try await execute(sut.useCase, acceptedPaymentMethodIds: ["master"])
        )
    }

    func test_execute_whenPaymentMethodFails_shouldPropagateError() async {
        // Arrange
        let sut = makeSUT()
        await sut.service.setPaymentMethodResult(.failure(MockBinFetchingService.MockError.resultNotSet))

        // Act / Assert
        await XCTAssertThrowsErrorAsync(try await execute(sut.useCase))
    }

    // MARK: - Payment Method Filtering

    func test_execute_whenEmptyAcceptedMethodIds_shouldMatchAnyBrand() async throws {
        // Arrange
        let sut = makeSUT()
        await sut.service.setPaymentMethodResult(.success([PaymentMethodStub.visa]))

        // Act
        let result = try await execute(sut.useCase, acceptedPaymentMethodIds: [])

        // Assert
        XCTAssertEqual(result.paymentMethod.id, PaymentMethodStub.visa.id)
    }

    func test_execute_whenAcceptedMethodIdsMatches_shouldReturnMatchingMethod() async throws {
        // Arrange
        let sut = makeSUT()
        await sut.service.setPaymentMethodResult(.success([PaymentMethodStub.visa, PaymentMethodStub.master]))

        // Act
        let result = try await execute(sut.useCase, acceptedPaymentMethodIds: ["master"])

        // Assert
        XCTAssertEqual(result.paymentMethod.id, PaymentMethodStub.master.id)
    }

    // MARK: - Issuer Fetching

    func test_execute_whenAdditionalInfoNeededHasNoIssuerId_shouldNotFetchIssuer() async throws {
        // Arrange
        let sut = makeSUT()
        await sut.service.setPaymentMethodResult(.success([PaymentMethodStub.visa]))

        // Act
        let result = try await execute(sut.useCase)

        // Assert — issuer fetch not attempted, result has no issuer
        XCTAssertNil(result.issuer)
    }

    func test_execute_whenAdditionalInfoNeededHasIssuerId_shouldFetchIssuer() async throws {
        // Arrange
        let sut = makeSUT()
        await sut.service.setPaymentMethodResult(.success([PaymentMethodStub.visaWithIssuer]))
        await sut.service.setIssuersResult(.success([IssuerStub.santander]))

        // Act
        let result = try await execute(sut.useCase)

        // Assert
        XCTAssertEqual(result.issuer?.id, IssuerStub.santander.id)
    }

    func test_execute_whenIssuersReturnsEmpty_shouldHaveNilIssuer() async throws {
        // Arrange
        let sut = makeSUT()
        await sut.service.setPaymentMethodResult(.success([PaymentMethodStub.visaWithIssuer]))
        await sut.service.setIssuersResult(.success([]))

        // Act
        let result = try await execute(sut.useCase)

        // Assert
        XCTAssertNil(result.issuer)
    }

    func test_execute_whenIssuersFails_shouldPropagateError() async {
        // Arrange
        let sut = makeSUT()
        await sut.service.setPaymentMethodResult(.success([PaymentMethodStub.visaWithIssuer]))
        await sut.service.setIssuersResult(.failure(MockBinFetchingService.MockError.resultNotSet))

        // Act / Assert
        await XCTAssertThrowsErrorAsync(try await execute(sut.useCase))
    }

    // MARK: - Installments Fetching

    func test_execute_whenAmountIsNil_shouldNotFetchInstallments() async throws {
        // Arrange
        let sut = makeSUT()
        await sut.service.setPaymentMethodResult(.success([PaymentMethodStub.visa]))

        // Act
        let result = try await execute(sut.useCase, amount: nil)

        // Assert
        XCTAssertNil(result.installment)
    }

    func test_execute_whenAmountProvided_shouldFetchInstallments() async throws {
        // Arrange
        let sut = makeSUT()
        await sut.service.setPaymentMethodResult(.success([PaymentMethodStub.visa]))
        await sut.service.setInstallmentsResult(.success([InstallmentStub.withSantander]))

        // Act
        let result = try await execute(sut.useCase, amount: 100.0)

        // Assert
        XCTAssertNotNil(result.installment)
    }

    func test_execute_whenAmountProvidedAndNoIssuer_shouldReturnFirstInstallment() async throws {
        // Arrange
        let sut = makeSUT()
        await sut.service.setPaymentMethodResult(.success([PaymentMethodStub.visa]))
        await sut.service.setInstallmentsResult(.success([InstallmentStub.withSantander, InstallmentStub.withBradesco]))

        // Act
        let result = try await execute(sut.useCase, amount: 100.0)

        // Assert
        XCTAssertEqual(result.installment, InstallmentStub.withSantander)
    }

    func test_execute_whenAmountProvidedWithIssuer_shouldMatchInstallmentByIssuer() async throws {
        // Arrange
        let sut = makeSUT()
        await sut.service.setPaymentMethodResult(.success([PaymentMethodStub.visaWithIssuer]))
        await sut.service.setIssuersResult(.success([IssuerStub.bradesco]))
        await sut.service.setInstallmentsResult(.success([InstallmentStub.withSantander, InstallmentStub.withBradesco]))

        // Act
        let result = try await execute(sut.useCase, amount: 100.0)

        // Assert — should pick bradesco installment, not the first one
        XCTAssertEqual(result.installment, InstallmentStub.withBradesco)
    }

    func test_execute_whenAmountProvidedWithIssuerButNoMatchingInstallment_shouldHaveNilInstallment() async throws {
        // Arrange
        let sut = makeSUT()
        await sut.service.setPaymentMethodResult(.success([PaymentMethodStub.visaWithIssuer]))
        await sut.service.setIssuersResult(.success([IssuerStub.santander]))
        await sut.service.setInstallmentsResult(.success([InstallmentStub.withBradesco]))

        // Act
        let result = try await execute(sut.useCase, amount: 100.0)

        // Assert — santander issuer but only bradesco installment available
        XCTAssertNil(result.installment)
    }

    func test_execute_whenInstallmentsFails_shouldPropagateError() async {
        // Arrange
        let sut = makeSUT()
        await sut.service.setPaymentMethodResult(.success([PaymentMethodStub.visa]))
        await sut.service.setInstallmentsResult(.failure(MockBinFetchingService.MockError.resultNotSet))

        // Act / Assert
        await XCTAssertThrowsErrorAsync(try await execute(sut.useCase, amount: 100.0))
    }
}

// MARK: - Async Test Helpers

private func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
        XCTFail("Expected expression to throw, but it succeeded.", file: file, line: line)
    } catch {}
}
