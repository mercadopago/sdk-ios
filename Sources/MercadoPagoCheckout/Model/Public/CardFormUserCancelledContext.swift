//
//  CardFormUserCancelledContext.swift
//  MercadoPagoSDK
//

/// Contains the state of all card form fields at the time the user cancelled the checkout.
public struct CardFormUserCancelledContext: Sendable, Equatable {
    /// The state of each field at the time of cancellation.
    public let fields: [FieldState]

    public init(fields: [FieldState]) {
        self.fields = fields
    }
}

extension CardFormUserCancelledContext {
    /// The state of a specific form field at cancellation time.
    public struct FieldState: Sendable, Equatable {
        /// The form field.
        public let field: Field
        /// The state of the field.
        public let state: State

        public init(field: Field, state: State) {
            self.field = field
            self.state = state
        }
    }
}

extension CardFormUserCancelledContext.FieldState {
    /// The form field identifiers.
    public enum Field: Sendable, Equatable {
        case cardNumber
        case cardHolder
        case expirationDate
        case securityCode
        case document
    }

    /// The state of a field at cancellation time.
    public enum State: Sendable, Equatable {
        /// The field was filled with a valid value.
        case valid
        /// The field was left empty.
        case empty
        /// The field was partially filled.
        case incomplete
        /// The field contained an invalid value.
        case invalid
        /// The card brand is not accepted by the seller.
        case cardBrandNotAccepted(brand: MercadoPagoCheckout.CardBrand)
        /// The card type is not accepted by the seller.
        case cardTypeNotAccepted(cardType: MercadoPagoCheckout.CardType?)
    }
}
