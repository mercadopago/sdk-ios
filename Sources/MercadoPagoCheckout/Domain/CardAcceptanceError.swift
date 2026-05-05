//
//  CardAcceptanceError.swift
//  MercadoPagoSDK
//

package enum CardAcceptanceError: Error, Equatable {
    case paymentMethodNotAllowed(String)
    case paymentTypeNotAllowed(String)
    case paymentMethodNotFound(String)
}
