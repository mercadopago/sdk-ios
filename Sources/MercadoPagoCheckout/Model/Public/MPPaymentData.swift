//
//  MPPaymentData.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 30/01/26.
//
import Foundation

public struct MPPaymentData: Codable, Sendable {
    var transactionAmount: Int
    var token: String?
    var installment: Int?
    var paymentMethodId: String?
    var issuerId: String?
    var payer: Payer = Payer()
    
    struct Payer: Codable, Sendable {
        var type: String?
        var number: String?
    }
}
