//
//  MercadoPagoCheckout + PaymentMethod.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 20/02/26.
//

public extension MercadoPagoCheckout {
    /// A payment method available during the checkout flow.
    enum PaymentMethod: Sendable {
        /// A credit, debit, or prepaid card payment.
        /// - Parameters:
        ///   - cardTypes: The card types accepted (e.g. `.credit`, `.debit`, `.prepaid`).
        ///   - cardBrands: The card brands accepted (e.g. `.visa`, `.mastercard`). Empty means all brands are accepted.
        ///   - installment: Installment options for this payment method. Defaults to ``Installment/init()``.
        case card(allowedTypes: [CardType] = CardType.defaults, allowedBrands: [CardBrand] = CardBrand.defaults, installment: Installment? = Installment())
        
        /// The default set of payment methods: card (credit, debit, prepaid), Pix, and Boleto.
        public static var defaults: [PaymentMethod] {
            [
                .card(allowedTypes: CardType.defaults, allowedBrands: CardBrand.defaults)
            ]
        }
    }
}

extension [MercadoPagoCheckout.PaymentMethod] {
    var acceptedPaymentTypeIds: [String] {
        flatMap { method -> [String] in
            guard case .card(let cardTypes, _, _) = method else { return [] }
            return cardTypes.map(\.paymentTypeId)
        }
    }

    var acceptedPaymentMethodIds: [String] {
        flatMap { method -> [String] in
            guard case .card(_, let cardBrands, _) = method else { return [] }
            return cardBrands.map(\.paymentMethodId)
        }
    }
}
