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
    /// - ``payment(configuration:)`` is only available when `T == MPPaymentData.PaymentTransaction`
    ///
    /// This propagates the concrete payment data type all the way through to
    /// ``MercadoPagoCheckoutResult`` at the call site.
    struct CheckoutType: Sendable {
        enum Kind: Sendable {
            case payment(MPPaymentSelectionConfiguration)
            case cardTransaction(MPOrder)
            case saveCard
        }

        let kind: Kind

        var configuration: any CheckoutTypeConfiguration {
            switch self.kind {
            case let .cardTransaction(order): return order
            case .saveCard: return SavedCardConfiguration()
            case let .payment(config): return config
            }
        }

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

public extension MercadoPagoCheckout.CheckoutType where T == MPPaymentData.PaymentTransaction {
    /// A payment selection flow that produces a ``MPPaymentData/PaymentTransaction``.
    ///
    /// - Parameter configuration: Configuration values for the payment selection, such as amount and payer.
    static func payment(
        configuration: MPPaymentSelectionConfiguration
    ) -> MercadoPagoCheckout<MPPaymentData.PaymentTransaction>.CheckoutType {
        .init(kind: .payment(configuration))
    }
}
