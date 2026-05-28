//
//  MPPaymentMethod.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 20/02/26.
//

/// A payment method available during the checkout flow.
public enum MPPaymentMethod: Sendable {
    /// A credit, debit, or prepaid card payment.
    /// - Parameters:
    ///   - cardTypes: The card types accepted (e.g. `.credit`, `.debit`, `.prepaid`).
    ///   - cardBrands: The card brands accepted (e.g. `.visa`, `.mastercard`). Empty means all brands are accepted.
    ///   - installment: Installment options for this payment method. Defaults to ``MPInstallment/init()``.
    case card(
        allowedTypes: [MPCardType] = MPCardType.defaults,
        allowedBrands: [MPCardBrand] = MPCardBrand.defaults,
        installment: MPInstallment? = MPInstallment()
    )

    /// The default set of payment methods: card (credit, debit, prepaid), Pix, and Boleto.
    public static var defaults: [MPPaymentMethod] {
        [
            .card(allowedTypes: MPCardType.defaults, allowedBrands: MPCardBrand.defaults)
        ]
    }
}

extension MPPaymentMethod {
    var acceptedPaymentTypeIds: [String] {
        guard case let .card(cardTypes, _, _) = self else { return [] }
        return cardTypes.map(\.paymentTypeId)
    }

    var acceptedPaymentMethodIds: [String] {
        guard case let .card(_, cardBrands, _) = self else { return [] }
        return cardBrands.map(\.paymentMethodId)
    }
}
