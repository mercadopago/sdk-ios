//
//  StatusScreenMapperTests.swift
//  MercadoPagoSDK
//

import Foundation
@testable import MercadoPagoCheckout
import XCTest

final class StatusScreenMapperTests: XCTestCase {
    func test_map_WhenURLsUseHTTP_ShouldAcceptPayload() throws {
        let sut = self.makeSUT()
        let json = self.validJSON
            .replacingOccurrences(
                of: "https://http2.mlstatic.com/success.png",
                with: "http://http2.mlstatic.com/success.png"
            )
            .replacingOccurrences(
                of: "https://www.mercadopago.com/receipt/test.pdf",
                with: "http://www.mercadopago.com/receipt/test.pdf"
            )

        let output = try sut.map(self.decode(json))

        XCTAssertEqual(output.header.iconURL, URL(string: "http://http2.mlstatic.com/success.png"))
        guard case let .openPDF(receiptURL) = output.footerButtons[1].action else {
            return XCTFail("Should preserve the open PDF action")
        }
        XCTAssertEqual(receiptURL, URL(string: "http://www.mercadopago.com/receipt/test.pdf"))
    }

    func test_map_WhenHeaderURLCannotBeParsed_ShouldRejectPayload() throws {
        let sut = self.makeSUT()
        let response = try self.decode(self.validJSON.replacingOccurrences(
            of: "https://http2.mlstatic.com/success.png",
            with: "https://["
        ))

        XCTAssertThrowsError(try sut.map(response)) { error in
            XCTAssertEqual(error as? StatusScreenContractError, .invalidHeader)
        }
    }

    func test_map_WhenBarcodeContainsImageURL_ShouldRejectPayload() throws {
        let sut = self.makeSUT()
        let json = self.validJSON.replacingOccurrences(
            of: "\"copy_feedback\": \"Copiado\"",
            with: "\"copy_feedback\": \"Copiado\", \"image_url\": \"https://http2.mlstatic.com/barcode.png\""
        )
        let response = try self.decode(json)

        XCTAssertThrowsError(try sut.map(response)) { error in
            XCTAssertEqual(error as? StatusScreenContractError, .invalidBody)
        }
    }

    func test_map_WhenFooterReceiptURLCannotBeParsed_ShouldRejectPayload() throws {
        let sut = self.makeSUT()
        let response = try self.decode(self.validJSON.replacingOccurrences(
            of: "https://www.mercadopago.com/receipt/test.pdf",
            with: "https://["
        ))

        XCTAssertThrowsError(try sut.map(response)) { error in
            XCTAssertEqual(error as? StatusScreenContractError, .invalidURL)
        }
    }

    func test_map_WhenFooterContainsKnownStyles_ShouldPreserveStyles() throws {
        let sut = self.makeSUT()
        let json = self.validJSON
            .replacingOccurrences(
                of: "\"action\": \"back_action\"",
                with: "\"action\": \"back_action\", \"style\": \"loud\""
            )
            .replacingOccurrences(
                of: "\"action\": \"open_pdf\"",
                with: "\"action\": \"open_pdf\", \"style\": \"quiet\""
            )

        let output = try sut.map(self.decode(json))

        XCTAssertEqual(output.footerButtons.map(\.style), [.loud, .quiet])
    }

    func test_map_WhenTextIsEmptyOrLong_ShouldAcceptPayload() throws {
        let sut = self.makeSUT()
        let longTitle = String(repeating: "a", count: 1024)
        let json = self.validJSON
            .replacingOccurrences(of: "Pagaste ($ 900)", with: longTitle)
            .replacingOccurrences(of: "Visa Crédito •••• 1234 · 3x $ 300", with: "")
            .replacingOccurrences(of: "$ 900 sin interés", with: "")
            .replacingOccurrences(of: "123456", with: "")
            .replacingOccurrences(of: "123 456", with: "")
            .replacingOccurrences(of: "Copiar", with: "")
            .replacingOccurrences(of: "Copiado", with: "")
            .replacingOccurrences(of: "Volver", with: "")

        let output = try sut.map(self.decode(json))

        XCTAssertEqual(output.header.title, longTitle)
        guard case let .listItem(payment) = output.body[1],
              case let .barcode(barcode) = output.body[2]
        else {
            return XCTFail("Should map the payment and barcode components")
        }
        XCTAssertEqual(payment.title, "")
        XCTAssertEqual(payment.subtitle, "")
        XCTAssertEqual(barcode.content, "")
        XCTAssertEqual(barcode.codeFormatted, "")
        XCTAssertEqual(barcode.copyLabel, "")
        XCTAssertEqual(barcode.copyFeedback, "")
        XCTAssertEqual(output.footerButtons[0].label, "")
    }

    func test_map_WhenSellerTitleIsEmptyOrMissing_ShouldAcceptPayload() throws {
        let sut = self.makeSUT()
        let jsonsWithoutSellerTitle = [
            self.validJSON.replacingOccurrences(of: "\"title\": \"Seller name\"", with: "\"title\": \"\""),
            self.validJSON.replacingOccurrences(of: "\"title\": \"Seller name\",", with: "")
        ]

        for json in jsonsWithoutSellerTitle {
            let output = try sut.map(self.decode(json))

            guard case let .listItem(seller) = output.body[0] else {
                return XCTFail("Should preserve the seller list item")
            }
            XCTAssertEqual(seller.title, "")
        }
    }

    func test_map_WhenBodyAndFooterAreEmpty_ShouldAcceptPayload() throws {
        let sut = self.makeSUT()
        let response = try self.decode(self.validJSON)
        let responseWithoutComponents = StatusScreenResponse(
            statusType: response.statusType,
            header: response.header,
            body: [],
            footer: .init(buttons: [])
        )

        let output = try sut.map(responseWithoutComponents)

        XCTAssertTrue(output.body.isEmpty)
        XCTAssertTrue(output.footerButtons.isEmpty)
    }

    func test_map_WhenBodyAndFooterExceedPreviousCeilings_ShouldAcceptPayload() throws {
        let sut = self.makeSUT()
        let response = try self.decode(self.validJSON)
        let expandedResponse = StatusScreenResponse(
            statusType: response.statusType,
            header: response.header,
            body: response.body + [response.body[2], response.body[0]],
            footer: .init(buttons: [
                response.footer.buttons[1],
                response.footer.buttons[0],
                response.footer.buttons[1]
            ])
        )

        let output = try sut.map(expandedResponse)

        XCTAssertEqual(output.body.count, 5)
        XCTAssertEqual(output.footerButtons.count, 3)
        guard case .openPDF = output.footerButtons[0].action else {
            return XCTFail("Should preserve footer action order")
        }
    }
}

private extension StatusScreenMapperTests {
    typealias SUT = StatusScreenMapper

    func makeSUT(file _: StaticString = #filePath, line _: UInt = #line) -> SUT {
        StatusScreenMapper()
    }

    func decode(_ json: String) throws -> StatusScreenResponse {
        try JSONDecoder().decode(StatusScreenResponse.self, from: Data(json.utf8))
    }

    var validJSON: String {
        """
        {
          "status_type": "approved",
          "header": {
            "title": "Pagaste ($ 900)",
            "icon": "https://http2.mlstatic.com/success.png"
          },
          "body": [
            {
              "component": "MPListItem",
              "data": {
                "title": "Seller name",
                "image_url": "https://http2.mlstatic.com/store.png"
              }
            },
            {
              "component": "MPListItem",
              "data": {
                "title": "Visa Crédito •••• 1234 · 3x $ 300",
                "subtitle": "$ 900 sin interés",
                "leading_type": "icon",
                "leading_value": "card"
              }
            },
            {
              "component": "MPBarcode",
              "data": {
                "content": "123456",
                "code_formatted": "123 456",
                "copy_label": "Copiar",
                "copy_feedback": "Copiado"
              }
            }
          ],
          "footer": {
            "buttons": [
              { "label": "Volver", "action": "back_action" },
              {
                "label": "Ver factura",
                "action": "open_pdf",
                "receipt_url": "https://www.mercadopago.com/receipt/test.pdf"
              }
            ]
          }
        }
        """
    }
}
