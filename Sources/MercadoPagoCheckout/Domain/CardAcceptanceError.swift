//
//  CardAcceptanceError.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 13/03/26.
//

package enum CardAcceptanceError: Error, Equatable {
    case paymentMethodNotAllowed(String)
    case paymentTypeNotAllowed(MercadoPagoCheckout.CardType?)
}
