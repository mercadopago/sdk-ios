@testable import CoreMethods
import Foundation

enum CardTokenStub {
    static let validTokenID = "teste"

    static var validResponse: Data {
        let response = """
        {
          "id": "teste",
          "public_key": "public_key",
          "first_six_digits": "422222",
          "expiration_month": 10,
          "expiration_year": 2032,
          "last_four_digits": "2222",
          "cardholder": {
            "identification": {
              "type": "DNI"
            },
            "name": "APRO"
          },
          "status": "active",
          "date_created": "2025-07-31T14:46:07.155-04:00",
          "date_last_updated": "2025-07-31T14:46:07.155-04:00",
          "date_due": "2025-08-08T14:46:07.155-04:00",
          "luhn_validation": true,
          "live_mode": true,
          "require_esc": false,
          "card_number_length": 12,
          "security_code_length": 3,
          "trunc_card_number": "422222XX2222"
        }
        """
        return Data(response.utf8)
    }

    static var expectedToken: CardToken {
        .init(
            token: validTokenID,
            publicKey: "public_key",
            bin: "422222",
            expirationMonth: 10,
            expirationYear: 2032,
            lastFourDigits: "2222",
            cardHolder: .init(
                identification: .init(type: "DNI"),
                name: "APRO"
            ),
            status: "active",
            dateCreated: "2025-07-31T14:46:07.155-04:00",
            dateLastUpdated: "2025-07-31T14:46:07.155-04:00",
            dateDue: "2025-08-08T14:46:07.155-04:00",
            luhnValidation: true,
            liveMode: true,
            requireEsc: false,
            cardNumberLength: 12,
            securityCodeLength: 3,
            truncCardNumber: "422222XX2222"
        )
    }
}
