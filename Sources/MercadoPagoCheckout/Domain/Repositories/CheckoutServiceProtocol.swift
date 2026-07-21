//
//  CheckoutServiceProtocol.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 23/02/26.
//
import CoreMethods

protocol CheckoutServiceProtocol: Sendable {
    func createCardToken(cardParams: CardParams) async throws(MercadoPagoCheckoutError) -> CardToken
}
