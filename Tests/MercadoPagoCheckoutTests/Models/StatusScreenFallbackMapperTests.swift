//
//  StatusScreenFallbackMapperTests.swift
//  MercadoPagoSDK
//

import Foundation
@testable import MercadoPagoCheckout
import XCTest

final class StatusScreenFallbackMapperTests: XCTestCase {
    func test_map_WhenApprovedCreditCardWithoutInterest_ShouldShowInstallmentsWithNoInterest() throws {
        let output = try makeOutput(
            status: "processed",
            type: "credit_card",
            installments: 3,
            totalAmount: "100.00",
            totalPaidAmount: "100.00"
        )

        XCTAssertEqual(output.statusType, "approved")
        XCTAssertEqual(output.header.icon, .badge(.positive))
        XCTAssertTrue(output.header.title.contains("100,00"))
        XCTAssertEqual(output.footerButtons.map(\.action), [.back])
        guard case let .listItem(item) = output.body.first else { return XCTFail("Should list the payment") }
        XCTAssertNil(item.leading)
        XCTAssertEqual(item.title, "Master •••• 1234")
        XCTAssertTrue(item.subtitle?.contains("3x") == true)
        XCTAssertTrue(item.subtitle?.contains("33,33") == true)
        XCTAssertTrue(item.subtitle?.contains("sin interés") == true || item.subtitle?.contains("sem acréscimo") == true)
    }

    func test_map_WhenInstallmentsHaveInterest_ShouldUsePaidAmountAndNotClaimNoInterest() throws {
        let output = try makeOutput(
            status: "processed",
            type: "credit_card",
            installments: 2,
            totalAmount: "1000.00",
            totalPaidAmount: "1167.50"
        )

        XCTAssertTrue(output.header.title.contains("1.167,50"))
        guard case let .listItem(item) = output.body.first else { return XCTFail("Should list the payment") }
        XCTAssertTrue(item.subtitle?.contains("2x") == true)
        XCTAssertTrue(item.subtitle?.contains("583,75") == true)
        XCTAssertFalse(item.subtitle?.contains("sin interés") == true || item.subtitle?.contains("sem acréscimo") == true)
    }

    func test_map_WhenPaidAmountIsMissing_ShouldOmitInstallmentBreakdown() throws {
        let output = try makeOutput(status: "processed", type: "credit_card", installments: 3, totalAmount: "100.00")

        guard case let .listItem(item) = output.body.first else { return XCTFail("Should list the payment") }
        XCTAssertFalse(item.subtitle?.contains("3x") == true)
        XCTAssertFalse(item.subtitle?.contains("sin interés") == true || item.subtitle?.contains("sem acréscimo") == true)
    }

    func test_map_WhenApprovedDebitCard_ShouldShowOnlyAmount() throws {
        let output = try makeOutput(status: "processed", type: "debit_card", installments: 3)

        guard case let .listItem(item) = output.body.first else { return XCTFail("Should list the payment") }
        XCTAssertEqual(item.title, "Master •••• 1234")
        XCTAssertFalse(item.subtitle?.contains("3x") == true)
        XCTAssertEqual(output.footerButtons.map(\.action), [.back])
    }

    func test_map_WhenTicket_ShouldPutOpenActionFirstThenBackAndRenderBarcodeOnly() throws {
        let output = try makeOutput(
            status: "action_required",
            type: "ticket",
            barcode: "0123456789",
            ticketURL: "https://example.invalid/ticket"
        )

        XCTAssertEqual(output.header.icon, .badge(.positive))
        XCTAssertEqual(output.body.count, 1)
        guard case let .barcode(barcode) = output.body.first else { return XCTFail("Should render the barcode") }
        XCTAssertEqual(barcode.content, "0123456789")
        XCTAssertEqual(output.footerButtons.count, 2)
        XCTAssertEqual(
            output.footerButtons[0].action,
            .openPDF(try XCTUnwrap(URL(string: "https://example.invalid/ticket")))
        )
        XCTAssertEqual(output.footerButtons[1].action, .back)
    }

    func test_map_WhenTicketHasPaymentMethodName_ShouldUseItInTheTitle() throws {
        let output = try makeOutput(status: "action_required", type: "ticket", paymentMethodName: "Pago Fácil")

        XCTAssertTrue(output.header.title.contains("Pago Fácil"))
        XCTAssertTrue(output.header.title.contains("100,00"))
    }

    func test_map_WhenTicketHasNoPaymentMethodName_ShouldFallBackToCapitalizedId() throws {
        let output = try makeOutput(status: "action_required", type: "ticket")

        XCTAssertTrue(output.header.title.contains("Rapipago"))
    }

    func test_map_WhenTicketHasOnlyRedirectURL_ShouldOpenRedirectURL() throws {
        let output = try makeOutput(
            status: "action_required",
            type: "ticket",
            redirectURL: "https://example.invalid/redirect"
        )

        XCTAssertEqual(
            output.footerButtons.first?.action,
            .openPDF(try XCTUnwrap(URL(string: "https://example.invalid/redirect")))
        )
    }

    func test_map_WhenTicketHasNoInstructions_ShouldOfferOnlyBack() throws {
        let output = try makeOutput(status: "action_required", type: "ticket")

        XCTAssertEqual(output.footerButtons.map(\.action), [.back])
        XCTAssertTrue(output.body.isEmpty)
    }

    func test_map_WhenInReview_ShouldShowPendingWithSingleBackAction() throws {
        let output = try makeOutput(status: "in_review", type: "credit_card")

        XCTAssertEqual(output.statusType, "pending")
        XCTAssertEqual(output.footerButtons.map(\.action), [.back])
    }

    func test_map_WhenRejected_ShouldNotBuildFallback() {
        let data = OrderTransactionProcessData(
            id: "O",
            status: "rejected",
            statusDetail: "",
            totalAmount: "1",
            payments: [.init(
                id: "P",
                status: "rejected",
                statusDetail: "",
                amount: "1",
                paymentMethodId: "master",
                paymentTypeId: "credit_card",
                installments: 1
            )]
        )

        XCTAssertNil(StatusScreenMapper().map(data, lastFourDigits: "1234"))
    }

    func test_map_WhenThereIsNoPayment_ShouldReturnNil() {
        let data = OrderTransactionProcessData(id: "O", status: "processed", statusDetail: "", totalAmount: "1", payments: [])

        XCTAssertNil(StatusScreenMapper().map(data, lastFourDigits: nil))
    }

    // MARK: - Helpers

    private func makeOutput(
        status: String,
        type: String,
        installments: Int? = nil,
        barcode: String? = nil,
        ticketURL: String? = nil,
        redirectURL: String? = nil,
        totalAmount: String = "100.00",
        totalPaidAmount: String? = nil,
        paymentMethodName: String? = nil
    ) throws -> StatusScreenOutput {
        let data = OrderTransactionProcessData(
            id: "ORDER",
            status: status,
            statusDetail: "detail",
            totalAmount: totalAmount,
            totalPaidAmount: totalPaidAmount,
            payments: [.init(
                id: "PAY",
                status: status,
                statusDetail: "detail",
                amount: "100.00",
                paymentMethodId: type == "ticket" ? "rapipago" : "master",
                paymentTypeId: type,
                installments: installments,
                barcodeContent: barcode,
                ticketURL: ticketURL,
                redirectURL: redirectURL
            )]
        )
        return try XCTUnwrap(StatusScreenMapper().map(data, lastFourDigits: "1234", paymentMethodName: paymentMethodName))
    }
}
