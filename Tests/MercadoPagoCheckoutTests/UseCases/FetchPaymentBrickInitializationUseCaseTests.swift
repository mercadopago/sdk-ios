//
//  FetchPaymentBrickInitializationUseCaseTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import XCTest

final class FetchPaymentBrickInitializationUseCaseTests: XCTestCase {
    // MARK: - Types

    typealias SUT = (
        useCase: FetchPaymentBrickInitializationUseCase,
        repository: MockPaymentBrickInitializationRepository
    )

    // MARK: - Success

    func test_execute_returnsOutputFromRepository() async throws {
        let sut = self.makeSUT()

        let output = try await sut.useCase.execute(orderId: "ORD01", totalAmount: 100, customerId: nil, cardIds: [])

        XCTAssertEqual(output, sut.repository.mockOutput)
    }

    func test_execute_forwardsParameters() async throws {
        let sut = self.makeSUT()

        _ = try await sut.useCase.execute(orderId: "ORD42", totalAmount: 500, customerId: "CUST01", cardIds: ["CARD1", "CARD2"])

        XCTAssertEqual(sut.repository.capturedOrderId, "ORD42")
        XCTAssertEqual(sut.repository.capturedCustomerId, "CUST01")
        XCTAssertEqual(sut.repository.capturedCardIds, ["CARD1", "CARD2"])
    }

    func test_execute_callsRepositoryOnce() async throws {
        let sut = self.makeSUT()

        _ = try await sut.useCase.execute(orderId: "ORD01", totalAmount: 100, customerId: nil, cardIds: [])

        XCTAssertEqual(sut.repository.fetchCallCount, 1)
    }

    // MARK: - Error

    func test_execute_repositoryThrows_mapsToCheckoutError() async {
        let sut = self.makeSUT()
        sut.repository.shouldThrow = true

        do {
            _ = try await sut.useCase.execute(orderId: "ORD01", totalAmount: 100, customerId: nil, cardIds: [])
            XCTFail("Expected throw")
        } catch let error as MercadoPagoCheckoutError {
            XCTAssertEqual(error.locationDescription, "initialization")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Helpers

    private func makeSUT() -> SUT {
        let repository = MockPaymentBrickInitializationRepository()
        let useCase = FetchPaymentBrickInitializationUseCase(repository: repository)
        return (useCase, repository)
    }
}
