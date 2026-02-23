//
//  MPPaymentData.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 30/01/26.
//
import Foundation

public struct MPPaymentData: Equatable, Codable, Sendable {
    public var transactionAmount: Double
    public var token: String?
    public var installment: Int?
    public var paymentMethodId: String?
    public var issuerId: String?
    public var payer: Payer?
    
    public struct Payer: Equatable, Codable, Sendable {
        var type: String
        var number: String
    }
}
