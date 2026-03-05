//
//  Installments.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 05/03/25.
//

import Foundation

public struct Installment: Sendable, Equatable {
    public let paymentMethodId: String
    public let paymentTypeId: String
    public let thumbnail: String
    public let issuer: Issuer
    public let processingMode: String
    public let merchantAccountId: String
    public let payerCosts: [PayerCost]
    public let agreements: [Agreement]

    public struct Issuer: Sendable, Equatable {
        public let id: String
        public let thumbnail: String
    }

    public struct PayerCost: Sendable, Equatable, Identifiable, Hashable {
        public var id: Int
        public let installments: Int
        public let installmentAmount: Double
        public let installmentRate: Double
        public let installmentRateCollector: [String]
        public let totalAmount: Double
        public let minAllowedAmount: Double
        public let maxAllowedAmount: Double
        public let discountRate: Double
        public let reimbursementRate: Double
        public let labels: [String]
        public let paymentMethodOptionId: String
    }

    public struct Agreement: Sendable, Equatable {
        public let merchantAccounts: [MerchantAccount]
        public let timeFrame: TimeFrame

        public struct MerchantAccount: Sendable, Equatable {
            public let id: String
            public let paymentMethodOptionId: String
        }

        public struct TimeFrame: Sendable, Equatable {
            public let startDate: String
            public let endDate: String
        }
    }
}
