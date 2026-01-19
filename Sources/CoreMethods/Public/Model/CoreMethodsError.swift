//
//  CoreMethodsError.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 29/09/25.
//
import Foundation

enum CoreMethodsError: Error, LocalizedError {
    case binIsEmpty
    case errorGettingEphemeralKey
    
    var errorDescription: String? {
        switch self {
        case .binIsEmpty:
            return "Bin is Empty"
        case .errorGettingEphemeralKey:
            return "Error getting ephemeral key"
        }
    }
}
