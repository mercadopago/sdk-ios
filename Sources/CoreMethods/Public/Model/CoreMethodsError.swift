//
//  CoreMethodsError.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 29/09/25.
//
import Foundation

enum CoreMethodsError: Error, LocalizedError {
    case binIsEmpty
    
    var errorDescription: String? {
        switch self {
        case .binIsEmpty:
            return "Bin is Empty"
        }
    }
}
