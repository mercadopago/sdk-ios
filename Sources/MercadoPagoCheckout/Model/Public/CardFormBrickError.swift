//
//  CardFormBrickError.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 30/01/26.
//
import Foundation

@frozen
public enum CardFormBrickError: Error, Equatable {
    case serviceError(String)
    case message(String)
}
