//
//  MPCancelledFormContext.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 13/03/26.
//

/// Contains information about the state of form fields when the user cancelled the checkout.
public struct MPCancelledFormContext: Sendable, Equatable {
    /// The list of fields that had errors at the time of cancellation.
    public let fieldErrors: [FieldError]

    public init(fieldErrors: [FieldError]) {
        self.fieldErrors = fieldErrors
    }
}

extension MPCancelledFormContext {
    /// Represents an error in a specific field.
    public struct FieldError: Sendable, Equatable {
        /// The field that had an error.
        public let field: Field
        /// The reason for the error.
        public let reason: Reason

        public init(field: Field, reason: Reason) {
            self.field = field
            self.reason = reason
        }
    }
}

extension MPCancelledFormContext.FieldError {
    /// The form field identifiers.
    public enum Field: Sendable, Equatable {
        case cardNumber
        case cardHolder
        case expirationDate
        case securityCode
        case document
    }

    /// The reason a field had an error.
    public enum Reason: Sendable, Equatable {
        /// The field was left empty.
        case empty
        /// The field was partially filled.
        case incomplete
        /// The field contained an invalid value.
        case invalid
        /// The card brand is not accepted.
        case cardBrandNotAccepted(brand: String)
        /// The card type is not accepted.
        case cardTypeNotAccepted(cardType: MercadoPagoCheckout.CardType?)
    }
}
