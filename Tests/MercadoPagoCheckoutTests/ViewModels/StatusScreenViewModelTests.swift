//
//  StatusScreenViewModelTests.swift
//  MercadoPagoSDK
//

import CommonTests
import Foundation
@testable import MercadoPagoCheckout
import XCTest

@MainActor
final class StatusScreenViewModelTests: XCTestCase {
    func test_load_WhenUseCaseSucceeds_ShouldBecomeReady() async {
        let output = makeOutput()
        let sut = makeSUT(behavior: .success(output))

        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.state, .ready(output))
    }

    func test_load_WhenCalled_ShouldForwardInputsToUseCase() async throws {
        let sellerInfo = MPSellerInfo(
            name: "Test Store",
            logoUrl: "https://example.com/store.png"
        )
        let sut = makeSUT(
            orderID: "ORDER-123",
            clientToken: "client-token",
            lastFourDigits: "0000",
            sellerInfo: sellerInfo
        )

        await sut.viewModel.load()

        let invocations = await sut.useCase.invocations
        let invocation = try XCTUnwrap(invocations.first)
        XCTAssertEqual(invocation.orderID, "ORDER-123")
        XCTAssertEqual(invocation.clientToken, "client-token")
        XCTAssertEqual(invocation.lastFourDigits, "0000")
        XCTAssertEqual(invocation.sellerInfo, sellerInfo)
    }

    func test_load_WhenCalledAfterReady_ShouldFetchOnlyOnce() async {
        let output = makeOutput()
        let sut = makeSUT(behavior: .success(output))

        await sut.viewModel.load()
        await sut.viewModel.load()

        let callCount = await sut.useCase.callCount
        XCTAssertEqual(sut.viewModel.state, .ready(output))
        XCTAssertEqual(callCount, 1)
    }

    func test_load_WhenRequestIsInFlight_ShouldStayLoadingAndFetchOnlyOnce() async {
        let output = makeOutput()
        let sut = makeSUT(behavior: .suspended(output))
        let firstLoad = Task { await sut.viewModel.load() }
        await sut.useCase.waitUntilCalled()

        await sut.viewModel.load()

        let callCount = await sut.useCase.callCount
        XCTAssertEqual(sut.viewModel.state, .loading)
        XCTAssertEqual(callCount, 1)

        await sut.useCase.resume()
        await firstLoad.value
        XCTAssertEqual(sut.viewModel.state, .ready(output))
    }

    func test_load_WhenUseCaseFails_ShouldBecomeUnavailable() async {
        let sut = makeSUT(behavior: .failure(makeError()))

        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.state, .unavailable)
    }

    func test_load_WhenCancelled_ShouldReturnToIdle() async {
        let sut = makeSUT(behavior: .suspended(makeOutput()))
        let load = Task { await sut.viewModel.load() }
        await sut.useCase.waitUntilCalled()

        load.cancel()
        XCTAssertEqual(sut.viewModel.state, .loading)
        await sut.useCase.resume()
        await load.value

        XCTAssertEqual(sut.viewModel.state, .idle)
    }

    func test_load_WhenCancelledAndUseCaseFails_ShouldReturnToIdle() async {
        let sut = makeSUT(behavior: .suspendedFailure(makeError()))
        let load = Task { await sut.viewModel.load() }
        await sut.useCase.waitUntilCalled()

        load.cancel()
        XCTAssertEqual(sut.viewModel.state, .loading)
        await sut.useCase.resume()
        await load.value

        XCTAssertEqual(sut.viewModel.state, .idle)
    }
}

private extension StatusScreenViewModelTests {
    typealias SUT = (
        viewModel: StatusScreenViewModel,
        useCase: MockStatusScreenUseCase
    )

    func makeSUT(
        orderID: String = "ORDER-TEST",
        clientToken: String = "client-token",
        lastFourDigits: String? = "0000",
        sellerInfo: MPSellerInfo? = nil,
        behavior: MockStatusScreenUseCase.Behavior? = nil,
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) -> SUT {
        let useCase = MockStatusScreenUseCase(
            behavior: behavior ?? .success(makeOutput())
        )
        let viewModel = StatusScreenViewModel(
            orderID: orderID,
            clientToken: clientToken,
            lastFourDigits: lastFourDigits,
            sellerInfo: sellerInfo,
            paymentTypeId: "ticket",
            useCase: useCase,
            analytics: MockAnalytics()
        )
        return (viewModel, useCase)
    }

    func makeOutput() -> StatusScreenOutput {
        guard let iconURL = URL(string: "https://example.com/status.png") else {
            fatalError("The test URL must be valid")
        }
        return StatusScreenOutput(
            statusType: "approved",
            header: .init(title: "Approved", iconURL: iconURL),
            body: [.listItem(.init(title: "Seller", subtitle: nil, leading: nil))],
            footerButtons: [.init(label: "Back", action: .back, style: nil)]
        )
    }

    func makeError() -> MercadoPagoCheckoutError {
        MercadoPagoCheckoutError(
            code: .serviceError,
            localizedDescription: "Unavailable",
            location: .initialization
        )
    }
}
