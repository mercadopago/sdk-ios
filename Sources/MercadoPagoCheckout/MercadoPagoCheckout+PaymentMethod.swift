//
//  MercadoPagoCheckout + PaymentMethod.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 20/02/26.
//

public extension MercadoPagoCheckout {
    /// A payment method available during the checkout flow.
    public enum PaymentMethod: Sendable {
        /// A credit, debit, or prepaid card payment.
        /// - Parameters:
        ///   - cardTypes: The card types accepted (e.g. `.credit`, `.debit`, `.prepaid`).
        ///   - installment: Installment options for this payment method. Defaults to ``Installment/init()``.
        case card(cardTypes: [CardType], installment: Installment? = Installment())
        /// Pix instant payment.
        case pix
        /// Boleto bank slip payment.
        case boleto
        /// Loan-based payment.
        ///
        /// - Parameter installment: Installment options for this payment method. Defaults to ``Installment/init()``.
        case loan(installment: Installment? = Installment())

        /// The default set of payment methods: card (credit, debit, prepaid), Pix, and Boleto.
        public static var defaults: [PaymentMethod] {
            [
                .card(cardTypes: [.credit, .debit, .prepaid]),
                .pix,
                .boleto
            ]
        }
    }
}

extension [MercadoPagoCheckout.PaymentMethod] {
    var acceptedPaymentTypeIds: [String] {
        flatMap { method -> [String] in
            guard case .card(let cardTypes, _) = method else { return [] }
            return cardTypes.map(\.paymentTypeId)
        }
    }
}
