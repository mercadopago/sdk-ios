//
//  MercadoPagoCheckout + CheckoutType.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 20/02/26.
//

public extension MercadoPagoCheckout {
    /// The type of checkout experience to launch.
    ///
    /// `CheckoutType` is parameterized by the outer ``MercadoPagoCheckout`` generic `T`, which
    /// represents the concrete ``MPPaymentData`` variant produced by the flow. Each factory
    /// is constrained so that:
    /// - ``cardTransaction(order:)`` is only available when `T == MPPaymentData.CardTransaction`
    /// - ``saveCard`` is only available when `T == MPPaymentData.CardSave`
    ///
    /// This propagates the concrete payment data type all the way through to
    /// ``MercadoPagoCheckoutResult`` at the call site.
    struct CheckoutType: Sendable {
        enum Kind: Sendable {
            case cardTransaction(MPOrder)
            case saveCard
        }

        let kind: Kind

        var analyticsValue: String {
            switch self.kind {
            case .cardTransaction: return "card_transaction"
            case .saveCard: return "save_card"
            }
        }
    }
}

public extension MercadoPagoCheckout.CheckoutType where T == MPPaymentData.CardTransaction {
    /// A card-based payment form that produces a ``MPPaymentData/CardTransaction``.
    ///
    /// - Parameter order: Configuration values for the transaction, such as amount and payer.
    static func cardTransaction(
        order: MPOrder
    ) -> MercadoPagoCheckout<MPPaymentData.CardTransaction>.CheckoutType {
        .init(kind: .cardTransaction(order))
    }
}

public extension MercadoPagoCheckout.CheckoutType where T == MPPaymentData.CardSave {
    /// A flow that saves a card without performing a transaction; produces a
    /// ``MPPaymentData/CardSave`` carrying the token.
    static var saveCard: MercadoPagoCheckout<MPPaymentData.CardSave>.CheckoutType {
        .init(kind: .saveCard)
    }
}
