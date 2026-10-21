//
//  StatusScreenPendingTests.swift
//  MercadoPagoSDK
//

import Foundation
@testable import MercadoPagoCheckout
import XCTest

final class StatusScreenPendingTests: XCTestCase {
    func test_map_WhenStatusIsPending_ShouldMapHeaderBodyAndFooter() throws {
        let cases: [(body: String, count: Int)] = [
            ("", 0),
            (self.messageNode, 1),
            (self.messageNode + "," + self.listItemNode, 2)
        ]

        for item in cases {
            let output = try self.map(self.json(body: item.body))

            XCTAssertEqual(output.statusType, "pending")
            XCTAssertEqual(output.header.title, "Payment pending")
            XCTAssertEqual(output.header.subtitle, "We are reviewing it")
            XCTAssertEqual(output.body.count, item.count)
            XCTAssertEqual(output.footerButtons.map(\.action), [.back])
            XCTAssertEqual(output.footerButtons.map(\.style), [.transparent])
        }
    }

    func test_map_WhenBodyContainsMessageAndRow_ShouldPreserveTextAndOrder() throws {
        let output = try self.map(self.json(body: self.messageNode + "," + self.listItemNode))

        guard case let .message(text) = output.body[0],
              case let .listItem(row) = output.body[1]
        else {
            return XCTFail("Should preserve the guidance and seller row")
        }
        XCTAssertEqual(text, "Check back later")
        XCTAssertEqual(row.title, "Seller name")
        XCTAssertNil(row.leading)
    }

    func test_map_WhenStatusIsUnrecognized_ShouldUseSharedMapping() throws {
        let output = try self.map(self.json(body: self.messageNode, statusType: "unknown"))

        XCTAssertEqual(output.statusType, "unknown")
        XCTAssertEqual(output.body, [.message("Check back later")])
        XCTAssertEqual(output.footerButtons.map(\.action), [.back])
    }

    func test_map_WhenApprovedContainsMessage_ShouldMapMessage() throws {
        let output = try self.map(self.json(body: self.messageNode, footer: "", statusType: "approved"))

        XCTAssertEqual(output.body, [.message("Check back later")])
    }

    func test_map_WhenPendingBodyContainsUnknownComponent_ShouldDropOnlyThatNode() throws {
        let unknown = self.messageNode.replacingOccurrences(of: "MPMessage", with: "MPUnknown")
        let output = try self.map(self.json(body: self.messageNode + "," + unknown + "," + self.listItemNode))
        let headerOnly = try self.map(self.json(body: unknown))

        XCTAssertEqual(output.body.count, 2)
        guard case .message = output.body[0], case .listItem = output.body[1] else {
            return XCTFail("Should keep the surviving body nodes in order")
        }
        XCTAssertTrue(headerOnly.body.isEmpty)
    }

    func test_map_WhenPendingBodyContainsMalformedMessage_ShouldDropOnlyThatNode() throws {
        let malformed = self.messageNode.replacingOccurrences(of: "\"text\"", with: "\"title\"")
        let output = try self.map(self.json(body: malformed + "," + self.messageNode))

        XCTAssertEqual(output.body, [.message("Check back later")])
    }

    func test_map_WhenPendingBodyHasDifferentCompositions_ShouldPreserveSupportedNodesInOrder() throws {
        let cases: [(body: String, expected: [String])] = [
            (self.listItemNode, ["listItem"]),
            (self.messageNode + "," + self.messageNode, ["message", "message"]),
            (self.listItemNode + "," + self.messageNode, ["listItem", "message"]),
            (self.messageNode + "," + self.listItemNode + "," + self.listItemNode, ["message", "listItem", "listItem"]),
            (self.messageNode + "," + self.barcodeNode, ["message", "barcode"])
        ]

        for item in cases {
            let output = try self.map(self.json(body: item.body))
            let actual = output.body.map { component in
                switch component {
                case .listItem: "listItem"
                case .barcode: "barcode"
                case .message: "message"
                }
            }
            XCTAssertEqual(actual, item.expected)
        }
    }

    func test_map_WhenPendingFooterVaries_ShouldUseSharedFooterMapping() throws {
        let openPDF = """
        {"label":"Receipt","action":"open_pdf","value":"https://www.mercadopago.com/receipt/test.pdf","style":"loud"}
        """
        let cases: [(footer: String, expectedStyles: [StatusScreenOutput.FooterButton.Style?])] = [
            ("", []),
            (self.backButton + "," + self.backButton, [.transparent, .transparent]),
            (self.backButton.replacingOccurrences(of: "transparent", with: "quiet"), [.quiet]),
            (self.backButton + "," + openPDF, [.transparent, .loud])
        ]

        for item in cases {
            let output = try self.map(self.json(body: "", footer: item.footer))
            XCTAssertEqual(output.footerButtons.map(\.style), item.expectedStyles)
        }

        let output = try self.map(self.json(body: "", footer: self.backButton + "," + openPDF))
        guard case let .openPDF(url) = output.footerButtons[1].action else {
            return XCTFail("Should preserve the receipt action")
        }
        XCTAssertEqual(url.absoluteString, "https://www.mercadopago.com/receipt/test.pdf")
    }

    func test_decode_WhenPendingFooterHasUnknownAction_ShouldRejectResponse() {
        let unknown = self.backButton.replacingOccurrences(of: "back_action", with: "retry_action")

        XCTAssertThrowsError(try self.decode(self.json(body: "", footer: unknown)))
    }
}

private extension StatusScreenPendingTests {
    var messageNode: String {
        """
        {"component":"MPMessage","data":{"text":"Check back later"}}
        """
    }

    var listItemNode: String {
        """
        {"component":"MPListItem","data":{"title":"Seller name"}}
        """
    }

    var barcodeNode: String {
        """
        {"component":"MPBarcode","data":{"content":"123","code_formatted":"123","copy_label":"Copy","copy_feedback":"Copied"}}
        """
    }

    var backButton: String {
        """
        {"label":"Back","action":"back_action","style":"transparent"}
        """
    }

    func json(body: String, footer: String? = nil, statusType: String = "pending") -> String {
        """
        {
          "status_type":"\(statusType)",
          "header":{
            "title":"Payment pending",
            "subtitle":"We are reviewing it",
            "icon":"https://http2.mlstatic.com/pending.png"
          },
          "body":[\(body)],
          "footer":{"buttons":[\(footer ?? self.backButton)]}
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
