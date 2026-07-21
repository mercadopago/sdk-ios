//
//  MPCardFormUserCancelledContext.swift
//  MercadoPagoSDK
//

/// A snapshot of every card form field at the moment the user cancelled the checkout.
///
/// Reachable from a card cancellation context such as
/// ``MPUserCancelledContext/CardTransaction/cardForm`` or
/// ``MPUserCancelledContext/CardSave/cardForm``. Use it to understand how complete the form was —
/// for example to pre-fill the valid fields if the user retries.
///
/// ## Topics
///
/// ### Field State
///
/// - ``fields``
/// - ``FieldState``
public struct MPCardFormUserCancelledContext: Sendable, Equatable {
    /// The state of each card form field at the moment of cancellation, one entry per field.
    public let fields: [FieldState]

    public init(fields: [FieldState]) {
        self.fields = fields
    }
}

extension MPCardFormUserCancelledContext {
    /// The state of a single card form field at the moment of cancellation.
    public struct FieldState: Sendable, Equatable {
        /// Which card form field this entry describes.
        public let field: CardFormField
        /// How the user had filled (or not filled) the field when they cancelled.
        public let state: State

        public init(field: CardFormField, state: State) {
            self.field = field
            self.state = state
        }
    }
}

extension MPCardFormUserCancelledContext.FieldState {
    /// How a card form field was filled at the moment the user cancelled.
    public enum State: Sendable, Equatable {
        /// The field held a complete, valid value.
        case valid
        /// The field was left empty.
        case empty
        /// The field was partially filled but not yet complete.
        case incomplete
        /// The field held a value that failed validation.
        case invalid
        /// The entered card's brand is not accepted by the seller.
        case cardBrandNotAccepted
        /// The entered card's type is not accepted by the seller.
        case cardTypeNotAccepted
    }
}
