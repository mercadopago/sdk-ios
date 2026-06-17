//
//  PaymentsViewModelTests.swift
//  MercadoPagoSDK
//

import Foundation
@testable import MercadoPagoCheckout
@testable import MPComponents
import XCTest

@MainActor
final class PaymentsViewModelTests: XCTestCase {
    // MARK: - title

    func test_title_isChooseHowToPay() {
        let sut = PaymentsViewModel(amount: 100)
        XCTAssertEqual(sut.title, "Escolha como pagar")
    }

    // MARK: - initialization

    func test_initialization_byDefault_hasSections() {
        let sut = PaymentsViewModel(amount: 100)
        XCTAssertFalse(sut.initialization.sections.isEmpty)
    }

    func test_initialization_withCustomValue_usesProvidedData() {
        let customOutput = PaymentInitializationOutput(sections: [
            .init(id: "test", title: "Test Section", items: [])
        ])
        let sut = PaymentsViewModel(amount: 100, initialization: customOutput)
        XCTAssertEqual(sut.initialization, customOutput)
    }

    // MARK: - amount

    func test_amount_currencySymbol_isNotEmpty() {
        let sut = PaymentsViewModel(amount: 500)
        XCTAssertFalse(sut.amount.currencySymbol.isEmpty)
    }

    func test_amount_withRoundValue_decimalPartIsZero() {
        let sut = PaymentsViewModel(amount: 500)
        XCTAssertEqual(sut.amount.decimalPart, "")
    }
}
