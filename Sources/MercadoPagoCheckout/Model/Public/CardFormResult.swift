//
//  CardFormResult.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 30/01/26.
//
import Foundation

@frozen
public enum CardFormResult: Equatable, Sendable {
    case success(MPPaymentData)
    case error(CardFormBrickError)
    case userCancelled
}
