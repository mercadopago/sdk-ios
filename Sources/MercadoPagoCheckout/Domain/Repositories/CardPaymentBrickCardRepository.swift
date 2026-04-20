//
//  CardPaymentBrickCardRepository.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 13/04/26.
//

protocol CardPaymentBrickCardRepository: Sendable {
    func fetchCard(params: CardPaymentBrickCardParams) async throws -> CardPaymentBrickCardData
}
