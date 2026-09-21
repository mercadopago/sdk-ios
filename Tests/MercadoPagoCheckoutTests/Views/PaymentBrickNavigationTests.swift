//
//  PaymentBrickNavigationTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import XCTest

@MainActor
final class PaymentBrickNavigationTests: XCTestCase {
    typealias SUT = PaymentBrick<MPPaymentData.Payment>

    func test_installmentsBackTransition_whenPreviousRouteIsSecurityCode_returnsSecurityCodeAndRecreatesScreen() {
        let transition = SUT.installmentsBackTransition(from: .securityCode)

        XCTAssertEqual(transition.destination, .securityCode)
        XCTAssertTrue(transition.shouldRecreateSecurityCode)
    }

    func test_installmentsBackTransition_whenPreviousRouteIsNil_returnsSelectorWithoutRecreatingScreen() {
        let transition = SUT.installmentsBackTransition(from: nil)

        XCTAssertNil(transition.destination)
        XCTAssertFalse(transition.shouldRecreateSecurityCode)
    }
}
