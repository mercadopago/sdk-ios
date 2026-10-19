//
//  StatusScreenProcessFailureTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import XCTest

final class StatusScreenProcessFailureTests: XCTestCase {
    func test_mapProcessFailure_ShouldShowNegativeBadgeNoBodyAndOnlyBack() {
        let output = StatusScreenMapper().mapProcessFailure()

        XCTAssertEqual(output.statusType, "rejected")
        XCTAssertEqual(output.header.icon, .badge(.negative))
        XCTAssertFalse(output.header.title.isEmpty)
        XCTAssertTrue(output.body.isEmpty)
        XCTAssertEqual(output.footerButtons.map(\.action), [.back])
    }

    func test_mapProcessFailure_ShouldNeverOfferChangePaymentMethod() {
        let output = StatusScreenMapper().mapProcessFailure()

        XCTAssertFalse(output.footerButtons.contains { $0.action == .changePaymentMethod })
    }
}
