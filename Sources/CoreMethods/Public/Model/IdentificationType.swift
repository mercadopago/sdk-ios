//
//  IdentificationType.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 25/02/25.
//
import Foundation

public struct IdentificationType: Sendable, Equatable {
    public let id: String
    public let name: String
    public let type: String
    public let minLenght: Int
    public let maxLenght: Int
}
