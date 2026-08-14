//
//  ReviewConfirmOutputTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import XCTest

final class ReviewConfirmOutputTests: XCTestCase {
    func test_initFromResponse_shouldCopyAllFields() throws {
        // Arrange
        let json = """
        {
          "header": { "title": "Revisá los datos antes de pagar" },
          "items": [
            { "type": "payment_method", "label": "Medio de pago", "value": "Visa •••• 4567" }
          ],
          "footer": { "button": { "label": "Pagar" }, "total_amount": "$ 110" }
        }
        """
        let response = try JSONDecoder().decode(ReviewConfirmResponse.self, from: Data(json.utf8))

        // Act
        let output = ReviewConfirmOutput(from: response)

        // Assert
        XCTAssertEqual(output.header.title, response.header.title)
        XCTAssertEqual(output.items.count, response.items.count)
        XCTAssertNil(output.footerSummary)
        XCTAssertEqual(output.footer.button.label, response.footer.button.label)
    }
}
