//
//  CardDisplayInfo.swift
//  MercadoPagoSDK
//

struct CardDisplayInfo: Equatable, Sendable {
    let issuerName: String
    let paymentTypeId: String
    let lastFourDigits: String
}
