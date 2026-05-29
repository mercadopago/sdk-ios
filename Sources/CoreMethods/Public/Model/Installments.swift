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

    package init(
        paymentMethodId: String,
        paymentTypeId: String,
        thumbnail: String,
        issuer: Issuer,
        processingMode: String,
        merchantAccountId: String,
        payerCosts: [PayerCost],
        agreements: [Agreement]
    ) {
        self.paymentMethodId = paymentMethodId
        self.paymentTypeId = paymentTypeId
        self.thumbnail = thumbnail
        self.issuer = issuer
        self.processingMode = processingMode
        self.merchantAccountId = merchantAccountId
        self.payerCosts = payerCosts
        self.agreements = agreements
    }

    public struct Issuer: Sendable, Equatable {
        public let id: String
        public let thumbnail: String
        public let name: String?

        package init(
            id: String,
            thumbnail: String,
            name: String? = nil
        ) {
            self.id = id
            self.thumbnail = thumbnail
            self.name = name
        }
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

        package init(
            id: Int,
            installments: Int,
            installmentAmount: Double,
            installmentRate: Double,
            installmentRateCollector: [String],
            totalAmount: Double,
            minAllowedAmount: Double,
            maxAllowedAmount: Double,
            discountRate: Double,
            reimbursementRate: Double,
            labels: [String],
            paymentMethodOptionId: String
        ) {
            self.id = id
            self.installments = installments
            self.installmentAmount = installmentAmount
            self.installmentRate = installmentRate
            self.installmentRateCollector = installmentRateCollector
            self.totalAmount = totalAmount
            self.minAllowedAmount = minAllowedAmount
            self.maxAllowedAmount = maxAllowedAmount
            self.discountRate = discountRate
            self.reimbursementRate = reimbursementRate
            self.labels = labels
            self.paymentMethodOptionId = paymentMethodOptionId
        }
    }

    public struct Agreement: Sendable, Equatable {
        public let merchantAccounts: [MerchantAccount]
        public let timeFrame: TimeFrame

        package init(merchantAccounts: [MerchantAccount], timeFrame: TimeFrame) {
            self.merchantAccounts = merchantAccounts
            self.timeFrame = timeFrame
        }

        public struct MerchantAccount: Sendable, Equatable {
            public let id: String
            public let paymentMethodOptionId: String

            package init(id: String, paymentMethodOptionId: String) {
                self.id = id
                self.paymentMethodOptionId = paymentMethodOptionId
            }
        }

        public struct TimeFrame: Sendable, Equatable {
            public let startDate: String
            public let endDate: String

            package init(startDate: String, endDate: String) {
                self.startDate = startDate
                self.endDate = endDate
            }
        }
    }
}
