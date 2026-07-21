//
//  MPInstallment.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 20/02/26.
//

/// Installment constraints for a payment method.
public struct MPInstallment: Sendable {
    /// The minimum number of installments allowed.
    public var minInstallments: Int
    /// The maximum number of installments allowed.
    public var maxInstallments: Int

    /// Creates a new installment configuration.
    ///
    /// - Parameters:
    ///   - minInstallments: The minimum number of installments. Defaults to `1`.
    ///   - maxInstallments: The maximum number of installments. Defaults to `180`.
    public init(minInstallments: Int = 1, maxInstallments: Int = 180) {
        self.minInstallments = minInstallments
        self.maxInstallments = maxInstallments
    }
}
