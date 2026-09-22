//
//  StatusScreenUseCaseTests.swift
//  MercadoPagoSDK
//

import Foundation
@testable import MercadoPagoCheckout
@testable import MPCore
import XCTest

final class StatusScreenUseCaseTests: XCTestCase {
    func test_execute_WhenSellerInfoProvided_ShouldSendMappedRequestAndClientToken() async throws {
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(self.makeResponse()))
        let sellerInfo = MPSellerInfo(
            name: "Test Store",
            logoUrl: "https://example.com/store.png"
        )

        _ = try await self.execute(
            sut: sut.useCase,
            orderID: "ORDER-TEST",
            clientToken: "client-token",
            lastFourDigits: "0000",
            sellerInfo: sellerInfo
        )

        let lastRequest = await sut.repository.lastRequest
        let clientToken = await sut.repository.lastClientToken
        let callCount = await sut.repository.callCount
        let request = try XCTUnwrap(lastRequest)
        XCTAssertEqual(request.orderID, "ORDER-TEST")
        XCTAssertEqual(request.lastFourDigits, "0000")
        XCTAssertEqual(request.sellerInfo?.name, "Test Store")
        XCTAssertEqual(request.sellerInfo?.iconURL, "https://example.com/store.png")
        XCTAssertEqual(clientToken, "client-token")
        XCTAssertEqual(callCount, 1)
    }

    func test_execute_WhenRepositorySucceeds_ShouldReturnMappedOutput() async throws {
        let sut = self.makeSUT()
        let response = self.makeResponse(
            title: "Payment approved",
            icon: "https://example.com/success.png"
        )
        await sut.repository.setResult(.success(response))

        let output = try await self.execute(sut: sut.useCase)

        XCTAssertEqual(output.header.title, "Payment approved")
        XCTAssertEqual(output.header.iconURL, URL(string: "https://example.com/success.png"))
        XCTAssertTrue(output.body.isEmpty)
        XCTAssertTrue(output.footerButtons.isEmpty)
    }

    func test_execute_WhenLastFourDigitsMissing_ShouldSendNilLastFourDigits() async throws {
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(self.makeResponse()))

        _ = try await self.execute(sut: sut.useCase, lastFourDigits: nil)

        let lastRequest = await sut.repository.lastRequest
        let request = try XCTUnwrap(lastRequest)
        XCTAssertNil(request.lastFourDigits)
    }

    func test_execute_WhenRepositoryThrowsDecodingFailed_ShouldThrowContractViolation() async {
        let sut = self.makeSUT()
        await sut.repository.setResult(.failure(APIClientError.decodingFailed(TestError.failure)))

        do {
            _ = try await self.execute(sut: sut.useCase)
            XCTFail("Should throw a contract violation")
        } catch {
            self.assertContractViolation(error)
        }
    }

    func test_execute_WhenMapperThrowsContractError_ShouldThrowContractViolation() async {
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(self.makeResponse(statusType: "pending")))

        do {
            _ = try await self.execute(sut: sut.useCase)
            XCTFail("Should throw a contract violation")
        } catch {
            self.assertContractViolation(error)
        }
    }

    func test_execute_WhenRepositoryThrowsNetworkError_ShouldMapAPIClientError() async {
        let sut = self.makeSUT()
        let networkError = APIClientError.networkError(URLError(.notConnectedToInternet))
        await sut.repository.setResult(.failure(networkError))

        do {
            _ = try await self.execute(sut: sut.useCase)
            XCTFail("Should throw a network error")
        } catch {
            XCTAssertEqual(error.code, .networkConnectionFailed)
            XCTAssertEqual(error.errorDescription, "No internet connection.")
            XCTAssertEqual(error.locationDescription, "initialization")
        }
    }

    func test_execute_WhenRepositoryThrowsGenericError_ShouldThrowUnavailableError() async {
        let sut = self.makeSUT()
        await sut.repository.setResult(.failure(TestError.failure))

        do {
            _ = try await self.execute(sut: sut.useCase)
            XCTFail("Should throw an unavailable error")
        } catch {
            XCTAssertEqual(error.code, .serviceError)
            XCTAssertEqual(error.errorDescription, "Status Screen is unavailable")
            XCTAssertEqual(error.locationDescription, "initialization")
        }
    }
}

private extension StatusScreenUseCaseTests {
    enum TestError: Error, Sendable {
        case failure
    }

    typealias SUT = (
        useCase: StatusScreenUseCase,
        repository: MockStatusScreenRepository
    )

    func makeSUT(file _: StaticString = #filePath, line _: UInt = #line) -> SUT {
        let repository = MockStatusScreenRepository()
        let useCase = StatusScreenUseCase(repository: repository)
        return (useCase, repository)
    }

    func execute(
        sut: StatusScreenUseCase,
        orderID: String = "ORDER-TEST",
        clientToken: String = "client-token",
        lastFourDigits: String? = "0000",
        sellerInfo: MPSellerInfo? = nil
    ) async throws(MercadoPagoCheckoutError) -> StatusScreenOutput {
        try await sut.execute(
            orderID: orderID,
            clientToken: clientToken,
            lastFourDigits: lastFourDigits,
            sellerInfo: sellerInfo
        )
    }

    func makeResponse(
        statusType: String = "approved",
        title: String = "Approved",
        icon: String = "https://example.com/status.png"
    ) -> StatusScreenResponse {
        StatusScreenResponse(
            statusType: statusType,
            header: .init(title: title, icon: icon),
            body: [],
            footer: .init(buttons: [])
        )
    }

    func assertContractViolation(
        _ error: MercadoPagoCheckoutError,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(error.code, .serviceError, file: file, line: line)
        XCTAssertEqual(error.errorDescription, "Status Screen contract violation", file: file, line: line)
        XCTAssertEqual(error.locationDescription, "initialization", file: file, line: line)
        XCTAssertEqual(
            error.errorUserInfo["status_screen_reason"] as? String,
            "contract_violation",
            file: file,
            line: line
        )
    }
}
