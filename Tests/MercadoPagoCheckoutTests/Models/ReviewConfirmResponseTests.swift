//
//  ReviewConfirmResponseTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import XCTest

final class ReviewConfirmResponseTests: XCTestCase {
    // MARK: - Full response

    func test_decode_fullResponse_shouldMapHeaderAndItems() throws {
        // Arrange / Act
        let response = try self.decodeFullResponse()

        // Assert
        XCTAssertEqual(response.header.title, "Revisá los datos antes de pagar")
        XCTAssertEqual(response.header.sellerName, "Loja do João")
        XCTAssertEqual(response.header.sellerIconUrl, "https://example.com/logo.png")

        XCTAssertEqual(response.items.count, 2)
        XCTAssertEqual(response.items[0].type, "payment_method")
        XCTAssertEqual(response.items[0].value, "Santander •••• 4567")
        XCTAssertEqual(response.items[0].changeLabel, "Modificar")
        XCTAssertEqual(response.items[1].type, "payer_email")
    }

    func test_decode_fullResponse_shouldMapFooterSummary() throws {
        // Arrange / Act
        let response = try self.decodeFullResponse()

        // Assert
        let footerSummary = try XCTUnwrap(response.footerSummary)
        let tooltip = "É uma diferenciação no preço de acordo com o número de parcelas."
        XCTAssertEqual(footerSummary.products?.first?.label, "Tênis")
        XCTAssertEqual(footerSummary.products?.first?.amount, "$ 100")
        XCTAssertEqual(footerSummary.coupon?.label, "DESCONTO10")
        XCTAssertEqual(footerSummary.interest?.title, "Acréscimo")
        XCTAssertEqual(footerSummary.interest?.tooltipMessage, tooltip)
    }

    func test_decode_fullResponse_shouldMapFooter() throws {
        // Arrange / Act
        let response = try self.decodeFullResponse()

        // Assert
        XCTAssertEqual(response.footer.button.label, "Pagar")
        XCTAssertEqual(response.footer.totalAmount, "$ 110")
        XCTAssertEqual(response.footer.installments?.label, "3x $105")
        XCTAssertEqual(response.footer.installments?.secondaryLabel, "Sin interés")
        XCTAssertEqual(response.footer.installments?.state, "success")
    }

    // MARK: - Optional fields

    func test_decode_withoutSellerInfo_shouldLeaveSellerFieldsNil() throws {
        // Arrange — credit_card via Payment: no seller configured, no footer_summary breakdown.
        let json = """
        {
          "header": { "title": "Revisá los datos antes de pagar" },
          "items": [
            { "type": "payment_method", "label": "Medio de pago", "value": "Visa •••• 4567" }
          ],
          "footer": {
            "button": { "label": "Pagar" },
            "total_amount": "$ 110"
          }
        }
        """
        let data = Data(json.utf8)

        // Act
        let response = try JSONDecoder().decode(ReviewConfirmResponse.self, from: data)

        // Assert
        XCTAssertNil(response.header.sellerName)
        XCTAssertNil(response.header.sellerIconUrl)
        XCTAssertNil(response.footerSummary)
        XCTAssertNil(response.items[0].changeLabel)
        XCTAssertNil(response.footer.installments)
    }

    func test_decode_itemWithoutChangeLabel_shouldNotShowModifyButton() throws {
        // Arrange — BFF omits change_label: SDK must not render "Modificar".
        let json = #"{"type":"payer_email","label":"E-mail","value":"t****@g****.com"}"#
        let data = Data(json.utf8)

        // Act
        let item = try JSONDecoder().decode(ReviewConfirmItem.self, from: data)

        // Assert
        XCTAssertNil(item.changeLabel)
    }

    // MARK: - Helpers

    private func decodeFullResponse() throws -> ReviewConfirmResponse {
        let json = """
        {
          "header": {
            "title": "Revisá los datos antes de pagar",
            "seller_name": "Loja do João",
            "seller_icon_url": "https://example.com/logo.png"
          },
          "items": [
            {
              "type": "payment_method",
              "label": "Medio de pago",
              "value": "Santander •••• 4567",
              "change_label": "Modificar"
            },
            {
              "type": "payer_email",
              "label": "E-mail",
              "value": "t****@g****.com",
              "change_label": "Modificar"
            }
          ],
          "footer_summary": {
            "products": [
              { "label": "Tênis", "amount": "$ 100" }
            ],
            "coupon": { "label": "DESCONTO10", "amount": "$ -10" },
            "interest": {
              "title": "Acréscimo",
              "tooltip_message": "É uma diferenciação no preço de acordo com o número de parcelas.",
              "amount": "$ 10"
            }
          },
          "footer": {
            "button": { "label": "Pagar" },
            "total_amount": "$ 110",
            "installments": {
              "label": "3x $105",
              "secondary_label": "Sin interés",
              "state": "success"
            }
          }
        }
        """
        return try JSONDecoder().decode(ReviewConfirmResponse.self, from: Data(json.utf8))
    }
}
