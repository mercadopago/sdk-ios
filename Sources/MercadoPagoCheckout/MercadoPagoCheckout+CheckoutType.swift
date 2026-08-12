//
//  MercadoPagoCheckout + CheckoutType.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 20/02/26.
//

public extension MercadoPagoCheckout {
    /// The type of checkout experience to launch.
    ///
    /// Pass one of the factory values to ``MercadoPagoCheckout/Builder`` to choose the flow:
    /// - ``cardTransaction(order:)`` charges a card for a given order and yields an
    ///   ``MercadoPagoCheckoutResult`` of ``MPPaymentData/CardTransaction``.
    /// - ``saveCard`` saves a card without charging it and yields an ``MercadoPagoCheckoutResult``
    ///   of ``MPPaymentData/CardSave``.
    ///
    /// The choice you make here determines the type of payment data and cancellation context your
    /// result closure receives, so you can read them without casting.
    struct CheckoutType: Sendable {
        enum Kind: Sendable {
            case payment(MPOrder, cardIds: [String], customerId: String?)
            case cardTransaction(MPOrder)
            case saveCard
        }

        let kind: Kind

        var analyticsValue: String {
            switch self.kind {
            case .cardTransaction: return "card_transaction"
            case .saveCard: return "save_card"
            case .payment: return "payment"
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

public extension MercadoPagoCheckout.CheckoutType where T == MPPaymentData.Payment {
    /// A payment selection flow that produces a ``MPPaymentData/Payment``.
    ///
    /// - Parameters:
    ///   - order: The order to process, including its `orderId` and `clientToken`.
    ///   - cardIds: Saved card IDs to display in the payment selector.
    ///     Pass an empty array when there are no saved cards to show.
    ///   - customerId: Alphanumeric customer ID (e.g. `"649457098-FybpOkG6zH8QRm"`).
    ///     Pass `nil` when there are no saved cards to show.
    static func payment(
        order: MPOrder,
        cardIds: [String] = [],
        customerId: String? = nil
    ) -> MercadoPagoCheckout<MPPaymentData.Payment>.CheckoutType {
        .init(kind: .payment(order, cardIds: cardIds, customerId: customerId))
    }
}
