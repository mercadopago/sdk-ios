//
//  CardFormResult.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 30/01/26.
//
import Foundation

@frozen
public enum MercadoPagoCheckoutResult: Sendable {
    case success(MPPaymentData)
    case error(MercadoPagoCheckoutError)
    case userCancelled(any UserCancelledContext)
}
