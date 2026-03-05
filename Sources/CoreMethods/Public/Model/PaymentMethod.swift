//
//  PaymentMethod.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 07/03/25.
//
import Foundation

public struct PaymentMethod: Sendable {
    public let id: String
    public let paymentTypeId: String
    public let status: String
    public let processingMode: String
    public let accreditationTime: Int
    public let merchantAccountId: String
    public let siteId: String
    public let thumbnail: String?
    public let minAccreditationDays: Int
    public let maxAccreditationDays: Int
    public let totalFinancialCost: Double
    public let financialInstitution: [FinancialInstitution]?
    public let issuer: Issuer?
    public let card: CardInfo?
    public let bins: [Int]?
    public let marketplace: String?
    public let deferredCapture: String?
    public let agreements: [Agreement]?
    public let payerCosts: [PayerCost]?
    public let labels: [String]?
    public let additionalInfoNeeded: [String]?

    public init(
        id: String,
        paymentTypeId: String,
        status: String,
        processingMode: String,
        accreditationTime: Int,
        merchantAccountId: String,
        siteId: String,
        thumbnail: String?,
        minAccreditationDays: Int,
        maxAccreditationDays: Int,
        totalFinancialCost: Double,
        financialInstitution: [FinancialInstitution]?,
        issuer: Issuer?,
        card: CardInfo?,
        bins: [Int]?,
        marketplace: String?,
        deferredCapture: String?,
        agreements: [Agreement]?,
        payerCosts: [PayerCost]?,
        labels: [String]?,
        additionalInfoNeeded: [String]?
    ) {
        self.id = id
        self.paymentTypeId = paymentTypeId
        self.status = status
        self.processingMode = processingMode
        self.accreditationTime = accreditationTime
        self.merchantAccountId = merchantAccountId
        self.siteId = siteId
        self.thumbnail = thumbnail
        self.minAccreditationDays = minAccreditationDays
        self.maxAccreditationDays = maxAccreditationDays
        self.totalFinancialCost = totalFinancialCost
        self.financialInstitution = financialInstitution
        self.issuer = issuer
        self.card = card
        self.bins = bins
        self.marketplace = marketplace
        self.deferredCapture = deferredCapture
        self.agreements = agreements
        self.payerCosts = payerCosts
        self.labels = labels
        self.additionalInfoNeeded = additionalInfoNeeded
    }

    public struct FinancialInstitution: Sendable {
        public let id: String
        public let description: String

        public init(id: String, description: String) {
            self.id = id
            self.description = description
        }
    }

    public struct Issuer: Sendable {
        public let id: Int
        public let isDefault: Bool
        public let thumbnail: String?

        public init(id: Int, isDefault: Bool, thumbnail: String?) {
            self.id = id
            self.isDefault = isDefault
            self.thumbnail = thumbnail
        }
    }

    public struct CardInfo: Sendable {
        public let bin: Int
        public let length: CardLength
        public let validation: String
        public let securityCode: SecurityCode

        public init(bin: Int, length: CardLength, validation: String, securityCode: SecurityCode) {
            self.bin = bin
            self.length = length
            self.validation = validation
            self.securityCode = securityCode
        }

        public struct CardLength: Sendable {
            public let min: Int
            public let max: Int

            public init(min: Int, max: Int) {
                self.min = min
                self.max = max
            }
        }

        public struct SecurityCode: Sendable {
            public let mode: String
            public let location: String
            public let length: Int

            public init(mode: String, location: String, length: Int) {
                self.mode = mode
                self.location = location
                self.length = length
            }
        }
    }

    public struct PayerCost: Sendable {
        public let installments: Int
        public let installmentRate: Double
        public let discountRate: Double
        public let reimbursementRate: Double
        public let minAllowedAmount: Double
        public let maxAllowedAmount: Double
        public let paymentMethodOptionId: String
        public let labels: [String]?

        public init(
            installments: Int,
            installmentRate: Double,
            discountRate: Double,
            reimbursementRate: Double,
            minAllowedAmount: Double,
            maxAllowedAmount: Double,
            paymentMethodOptionId: String,
            labels: [String]?
        ) {
            self.installments = installments
            self.installmentRate = installmentRate
            self.discountRate = discountRate
            self.reimbursementRate = reimbursementRate
            self.minAllowedAmount = minAllowedAmount
            self.maxAllowedAmount = maxAllowedAmount
            self.paymentMethodOptionId = paymentMethodOptionId
            self.labels = labels
        }
    }

    public struct Agreement: Sendable {
        public let timeFrame: TimeFrame
        public let merchantAccounts: [MerchantAccount]

        public init(timeFrame: TimeFrame, merchantAccounts: [MerchantAccount]) {
            self.timeFrame = timeFrame
            self.merchantAccounts = merchantAccounts
        }

        public struct TimeFrame: Sendable {
            public let startDate: Date
            public let endDate: Date

            public init(startDate: Date, endDate: Date) {
                self.startDate = startDate
                self.endDate = endDate
            }
        }

        public struct MerchantAccount: Sendable {
            public let id: String
            public let paymentMethodOptionId: String

            public init(id: String, paymentMethodOptionId: String) {
                self.id = id
                self.paymentMethodOptionId = paymentMethodOptionId
            }
        }
    }
}
