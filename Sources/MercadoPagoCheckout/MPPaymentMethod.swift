//
//  MPPaymentMethod.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 20/02/26.
//

/// A payment method configuration for the checkout flow.
public enum MPPaymentMethodConfig: Sendable {
    /// A credit, debit, or prepaid card payment.
    /// - Parameters:
    ///   - excludedTypes: The card types to exclude (e.g. `.prepaid`). Empty means all types are accepted.
    ///   - excludedBrands: The card brands to exclude (e.g. `.amex`). Empty means all brands are accepted.
    ///   - installment: Installment options for this payment method. Defaults to ``MPInstallment/init()``.
    case card(
        excludedTypes: [MPCardType] = [],
        excludedBrands: [MPCardBrand] = [],
        installment: MPInstallment? = MPInstallment()
    )
    
    public static var defaults: [MPPaymentMethodConfig] {
        [
            .card(excludedTypes: [], excludedBrands: [])
        ]
    }
}

extension [MPPaymentMethodConfig] {
    var excludedPaymentTypeIds: [String] {
        flatMap { method -> [String] in
            guard case let .card(excludedTypes, _, _) = method else { return [] }
            return excludedTypes.map(\.paymentTypeId)
        }
    }

    var excludedPaymentMethodIds: [String] {
        flatMap { method -> [String] in
            guard case let .card(_, excludedBrands, _) = method else { return [] }
            return excludedBrands.map(\.paymentMethodId)
        }
    }
}
