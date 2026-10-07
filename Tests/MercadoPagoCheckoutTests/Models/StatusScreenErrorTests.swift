//
//  StatusScreenErrorTests.swift
//  MercadoPagoSDK
//

import Foundation
@testable import MercadoPagoCheckout
import XCTest

final class StatusScreenErrorTests: XCTestCase {
    func test_map_WhenRejectedBodyAndFooterAreOrdered_ShouldPreserveBothVariants() throws {
        for canRetry in [false, true] {
            let response = try self.decode(self.json(canRetry: canRetry))
            let output = try StatusScreenMapper().map(response)

            XCTAssertEqual(response.canRetry, canRetry)
            XCTAssertEqual(output.statusType, "rejected")
            XCTAssertEqual(output.canRetry, canRetry)
            XCTAssertEqual(output.body.count, 3)
            guard case let .listItem(seller) = output.body[0],
                  case let .listItem(payment) = output.body[1],
                  case let .message(guidance) = output.body[2]
            else {
                return XCTFail("Should preserve the rejected body order")
            }
            XCTAssertEqual(seller.title, "Seller")
            XCTAssertEqual(payment.title, "Card ending 1234")
            XCTAssertEqual(guidance, "Choose another payment method")
            XCTAssertEqual(output.footerButtons.map(\.action), canRetry ? [.changePaymentMethod, .back] : [.back])
        }
    }

    func test_map_WhenRejectedBodyOrderChanges_ShouldPreservePayloadOrder() throws {
        let output = try self.map(self.json(body: self.seller + "," + self.guidance + "," + self.payment))

        XCTAssertEqual(output.body, [
            .listItem(.init(title: "Seller", subtitle: nil, leading: nil)),
            .message("Choose another payment method"),
            .listItem(.init(title: "Card ending 1234", subtitle: nil, leading: nil))
        ])
    }

    func test_map_WhenRejectedBodyHasUnknownComponent_ShouldDropOnlyThatNode() throws {
        let body = self.seller + "," + self.payment + "," + self.guidance.replacingOccurrences(
            of: "MPMessage", with: "MPUnknown"
        )
        let output = try self.map(self.json(body: body))

        XCTAssertEqual(output.body.count, 2)
        guard case .listItem = output.body[0], case .listItem = output.body[1] else {
            return XCTFail("Should keep both known list items")
        }
    }

    func test_map_WhenRejectedListItemHasNoTitle_ShouldKeepItemWithEmptyTitle() throws {
        let body = self.seller.replacingOccurrences(of: "\"title\":\"Seller\"", with: "")
            + "," + self.payment + "," + self.guidance
        let output = try self.map(self.json(body: body))

        guard case let .listItem(seller) = output.body[0] else {
            return XCTFail("Should keep the seller row")
        }
        XCTAssertEqual(seller.title, "")
    }

    func test_map_WhenSimpleListRowUsesBillIcon_ShouldKeepTheRow() throws {
        let billRow = "{\"component\":\"MPListItem\",\"data\":{\"title\":\"N.º da transação 1234567890\",\"leading_type\":\"icon\",\"leading_value\":\"bill\",\"style\":\"simple\"}}"
        let output = try self.map(self.json(body: billRow))

        XCTAssertEqual(output.body, [
            .listItem(.init(title: "N.º da transação 1234567890", subtitle: nil, leading: .billIcon, style: .simple))
        ])
    }

    func test_map_WhenListItemStyleIsDefaultOrMissing_ShouldUseRegularListItem() throws {
        let defaultRow = "{\"component\":\"MPListItem\",\"data\":{\"title\":\"Default row\",\"style\":\"default\"}}"
        let missingStyleRow = "{\"component\":\"MPListItem\",\"data\":{\"title\":\"Missing style row\"}}"
        let output = try self.map(self.json(body: defaultRow + "," + missingStyleRow))

        XCTAssertEqual(output.body, [
            .listItem(.init(title: "Default row", subtitle: nil, leading: nil)),
            .listItem(.init(title: "Missing style row", subtitle: nil, leading: nil))
        ])
    }

    func test_map_WhenRejectedBodyIsEmpty_ShouldAcceptPayload() throws {
        let emptyBodyJSON = self.json(body: "")
        let output = try self.map(emptyBodyJSON)

        XCTAssertTrue(output.body.isEmpty)
        XCTAssertEqual(output.footerButtons.map(\.action), [.changePaymentMethod, .back])
    }

    func test_map_WhenFooterCompositionChanges_ShouldPreservePayloadActions() throws {
        let cases: [(footer: String, actions: [StatusScreenOutput.FooterButton.Action])] = [
            ("", []),
            (self.retryButton, [.changePaymentMethod]),
            (self.backButton + "," + self.retryButton, [.back, .changePaymentMethod]),
            (self.backButton + "," + self.backButton, [.back, .back]),
            (
                self.retryButton + "," + self.retryButton + "," + self.backButton,
                [.changePaymentMethod, .changePaymentMethod, .back]
            )
        ]

        for item in cases {
            let output = try self.map(self.json(footer: item.footer))
            XCTAssertEqual(output.footerButtons.map(\.action), item.actions)
        }
    }

    func test_decode_WhenRejectedFooterActionIsUnknown_ShouldRejectPayload() {
        let footer = self.backButton.replacingOccurrences(of: "back_action", with: "unknown")
        XCTAssertThrowsError(try self.decode(self.json(footer: footer)))
    }

    func test_map_WhenFooterStyleIsMissingOrUnknown_ShouldKeepActionWithoutStyle() throws {
        let cases = [
            self.backButton.replacingOccurrences(of: ",\"style\":\"transparent\"", with: ""),
            self.backButton.replacingOccurrences(of: "transparent", with: "unsupported")
        ]
        for footer in cases {
            let output = try self.map(self.json(canRetry: false, footer: footer))
            XCTAssertEqual(output.footerButtons.map(\.action), [.back])
            XCTAssertNil(output.footerButtons[0].style)
        }
    }

    func test_map_WhenRetryButtonIsPresent_ShouldMapRegardlessOfCanRetry() throws {
        for canRetry in [false, nil] as [Bool?] {
            let output = try self.map(self.json(canRetry: canRetry, footer: self.retryButton + "," + self.backButton))
            XCTAssertEqual(output.footerButtons.map(\.action), [.changePaymentMethod, .back])
            XCTAssertEqual(output.canRetry, canRetry)
        }
    }

    func test_map_WhenRetryButtonIsAbsent_ShouldAcceptAnyRetryFlag() throws {
        for canRetry in [true, false, nil] as [Bool?] {
            let output = try self.map(self.json(canRetry: canRetry, footer: self.backButton))
            XCTAssertEqual(output.footerButtons.map(\.action), [.back])
            XCTAssertEqual(output.canRetry, canRetry)
        }
    }

    func test_map_WhenRetryButtonHasUnusedValue_ShouldMapAction() throws {
        let footer = self.retryButton.replacingOccurrences(of: "\"style\"", with: "\"value\":\"unexpected\",\"style\"")
        let output = try self.map(self.json(footer: footer + "," + self.backButton))
        XCTAssertEqual(output.footerButtons.map(\.action), [.changePaymentMethod, .back])
    }

    func test_decode_WhenSuccessAndPendingOmitCanRetry_ShouldRemainCompatible() throws {
        for statusType in ["approved", "pending"] {
            let json = self.json(canRetry: nil, body: "", footer: self.backButton)
                .replacingOccurrences(of: "\"rejected\"", with: "\"\(statusType)\"")
            let response = try self.decode(json)
            let output = try StatusScreenMapper().map(response)

            XCTAssertNil(response.canRetry)
            XCTAssertNil(output.canRetry)
        }
    }
}

private extension StatusScreenErrorTests {
    var seller: String { "{\"component\":\"MPListItem\",\"data\":{\"title\":\"Seller\"}}" }
    var payment: String { "{\"component\":\"MPListItem\",\"data\":{\"title\":\"Card ending 1234\"}}" }
    var guidance: String { "{\"component\":\"MPMessage\",\"data\":{\"text\":\"Choose another payment method\"}}" }
    var backButton: String { "{\"label\":\"Back\",\"action\":\"back_action\",\"style\":\"transparent\"}" }
    var retryButton: String { "{\"label\":\"Retry\",\"action\":\"change_payment_method\",\"style\":\"loud\"}" }

    func json(canRetry: Bool? = true, body: String? = nil, footer: String? = nil) -> String {
        let retryField = canRetry.map { "\"can_retry\":\($0)," } ?? ""
        let body = body ?? self.seller + "," + self.payment + "," + self.guidance
        let footer = footer ?? (canRetry == true ? self.retryButton + "," + self.backButton : self.backButton)
        return """
        {
          "status_type":"rejected",
          \(retryField)
          "header":{"title":"Payment rejected","icon":"https://http2.mlstatic.com/error.png"},
          "body":[\(body)],
          "footer":{"buttons":[\(footer)]}
        }
        """
    }

    func decode(_ json: String) throws -> StatusScreenResponse {
        try JSONDecoder().decode(StatusScreenResponse.self, from: Data(json.utf8))
    }

    func map(_ json: String) throws -> StatusScreenOutput {
        try StatusScreenMapper().map(self.decode(json))
    }
}
