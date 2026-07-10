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
        repository: MockPaymentBrickRepository
    )

    // MARK: - Success

    func test_execute_returnsOutputFromRepository() async throws {
        let sut = self.makeSUT()

        let output = try await sut.useCase.execute(orderId: "ORD01", clientToken: "tok")

        XCTAssertEqual(output, sut.repository.mockOutput)
    }

    func test_execute_forwardsOrderId() async throws {
        let sut = self.makeSUT()

        _ = try await sut.useCase.execute(orderId: "ORD42", clientToken: "tok")

        XCTAssertEqual(sut.repository.capturedOrderId, "ORD42")
    }

    func test_execute_forwardsClientToken() async throws {
        let sut = self.makeSUT()

        _ = try await sut.useCase.execute(orderId: "ORD01", clientToken: "seller_token")

        XCTAssertEqual(sut.repository.capturedClientToken, "seller_token")
    }

    func test_execute_callsRepositoryOnce() async throws {
        let sut = self.makeSUT()

        _ = try await sut.useCase.execute(orderId: "ORD01", clientToken: "tok")

        XCTAssertEqual(sut.repository.fetchCallCount, 1)
    }

    // MARK: - Error

    func test_execute_repositoryThrows_mapsToCheckoutError() async {
        let sut = self.makeSUT()
        sut.repository.shouldThrow = true

        do {
            _ = try await sut.useCase.execute(orderId: "ORD01", clientToken: "tok")
            XCTFail("Expected throw")
        } catch let error as MercadoPagoCheckoutError {
            XCTAssertEqual(error.locationDescription, "initialization")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Helpers

    private func makeSUT() -> SUT {
        let repository = MockPaymentBrickRepository()
        let useCase = FetchPaymentBrickInitializationUseCase(repository: repository)
        return (useCase, repository)
    }
}
