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

    func test_title_usesHeaderTitleFromOutput() {
        let output = PaymentInitializationOutput(
            headerTitle: "Cómo querés pagar",
            sections: [],
            footer: .init(totalLabel: "Total", totalAmount: "$ 15")
        )
        let sut = PaymentsViewModel(initialization: output)
        XCTAssertEqual(sut.title, "Cómo querés pagar")
    }

    func test_totalLabel_usesFooterTotalLabelFromOutput() {
        let output = PaymentInitializationOutput(
            headerTitle: "Header",
            sections: [],
            footer: .init(totalLabel: "Valor total", totalAmount: "$ 15")
        )
        let sut = PaymentsViewModel(initialization: output)
        XCTAssertEqual(sut.totalLabel, "Valor total")
    }

    // MARK: - initialization

    func test_initialization_byDefault_hasSections() {
        let sut = PaymentsViewModel()
        XCTAssertFalse(sut.initialization.sections.isEmpty)
    }

    func test_initialization_withCustomValue_usesProvidedData() {
        let customOutput = PaymentInitializationOutput(
            headerTitle: "Cómo querés pagar",
            sections: [.init(id: "test", title: "Test Section", items: [])],
            footer: .init(totalLabel: "Total", totalAmount: "$ 15")
        )
        let sut = PaymentsViewModel(initialization: customOutput)
        XCTAssertEqual(sut.initialization, customOutput)
    }

    // MARK: - amount

    func test_amount_parsedFromFooterTotalAmount() {
        let output = PaymentInitializationOutput(
            headerTitle: "Header",
            sections: [],
            footer: .init(totalLabel: "Total", totalAmount: "R$ 1.250,99")
        )
        let sut = PaymentsViewModel(initialization: output)
        XCTAssertEqual(sut.amount.currencySymbol, "R$")
        XCTAssertEqual(sut.amount.integerPart, "1.250")
        XCTAssertEqual(sut.amount.decimalPart, "99")
    }

    func test_amount_withRoundValue_decimalPartIsEmpty() {
        let output = PaymentInitializationOutput(
            headerTitle: "Header",
            sections: [],
            footer: .init(totalLabel: "Total", totalAmount: "$ 500,00")
        )
        let sut = PaymentsViewModel(initialization: output)
        XCTAssertEqual(sut.amount.decimalPart, "")
    }
}
