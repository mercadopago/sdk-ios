//
//  MPPaymentData.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 30/01/26.
//
import Foundation

public struct MPPaymentData: Equatable, Codable, Sendable {
    public var transactionAmount: Double?
    public var token: String
    public var installment: Int?
    public var paymentMethodId: String
    public var paymentTypeId: String
    public var issuerId: String?
    public var payer: Payer?

    public struct Payer: Equatable, Codable, Sendable {
        public var documentType: String
        public var documentNumber: String
    }
}

extension MPPaymentData {
    init(
        transactionAmount: Double? = nil,
        token: String? = nil,
        installment: Int? = nil,
        paymentMethodId: String? = nil,
        paymentTypeId: String? = nil,
        issuerId: String? = nil,
        payer: Payer? = nil
    ) {
        self.transactionAmount = transactionAmount
        self.token = token ?? ""
        self.installment = installment
        self.paymentMethodId = paymentMethodId ?? ""
        self.paymentTypeId = paymentTypeId ?? ""
        self.issuerId = issuerId
        self.payer = payer
    }
}
