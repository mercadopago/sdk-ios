//
//  MPUserCancelledContext.swift
//  MercadoPagoSDK
//

/// Describes what the user had done at the moment they abandoned a checkout flow.
///
/// You receive one of these in ``MercadoPagoCheckoutResult/userCancelled(_:)`` when the user
/// dismisses the checkout before completing it. This namespace groups the cancellation variants;
/// the one you actually get is fixed by the ``MercadoPagoCheckout/CheckoutType`` you configured,
/// so you never need to cast: `.cardTransaction(order:)` delivers a ``CardTransaction``, and
/// `.saveCard` delivers a ``CardSave``.
///
/// Use this context to power retry experiences (for example, pre-filling fields the user already
/// entered) or to report cancellation analytics.
///
/// ## Topics
///
/// ### Variants
///
/// - ``CardTransaction``
/// - ``CardSave``
/// - ``Payment``
///
/// ### Inspecting What the User Reached
///
/// - ``MPCardFormUserCancelledContext``
/// - ``Screen``
public enum MPUserCancelledContext {
    /// Marker protocol adopted by every cancellation variant in this namespace.
    public protocol Kind: Sendable, Equatable {}

    /// Cancellation context delivered when the user abandons the `.saveCard` flow.
    public struct CardSave: Kind {
        /// The per-field state of the card form at the moment of cancellation.
        ///
        /// Inspect this to see which fields were already valid, empty, or invalid so you can
        /// restore them on a later attempt.
        public let cardForm: MPCardFormUserCancelledContext

        public init(cardForm: MPCardFormUserCancelledContext) {
            self.cardForm = cardForm
        }
    }

    /// Cancellation context delivered when the user abandons the `.cardTransaction(order:)` flow.
    public struct CardTransaction: Kind {
        /// The per-field state of the card form at the moment of cancellation.
        ///
        /// Inspect this to see which fields were already valid, empty, or invalid so you can
        /// restore them on a later attempt.
        public let cardForm: MPCardFormUserCancelledContext

        /// The screens the user visited, in the order they reached them, before cancelling.
        ///
        /// Empty when the user cancelled directly from the card form without advancing further.
        public let screens: [MPScreen]

        public init(cardForm: MPCardFormUserCancelledContext, screens: [MPScreen] = []) {
            self.cardForm = cardForm
            self.screens = screens
        }
    }

    /// Cancellation context for the PaymentBrick (payment method selector) flow.
    public struct Payment: Kind {
        /// The screens the user visited, in the order they reached them, before cancelling.
        ///
        /// Empty when the user cancelled directly from the selector without advancing.
        public let screens: [MPScreen]

        public init(screens: [MPScreen] = []) {
            self.screens = screens
        }
    }
}
