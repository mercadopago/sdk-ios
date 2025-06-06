//
//  IdentificationType.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 25/02/25.
//
import Foundation

public struct IdentificationType: Sendable, Equatable, Hashable {
    public let id: String
    public let name: String
    public let type: String
    public let minLenght: Int
    public let maxLenght: Int
    
    public init(id: String, name: String, type: String, minLenght: Int, maxLenght: Int) {
        self.id = id
        self.name = name
        self.type = type
        self.minLenght = minLenght
        self.maxLenght = maxLenght
    }
    
    public init(name: String) {
        self.id = ""
        self.name = name
        self.type = ""
        self.minLenght = 0
        self.maxLenght = 0
    }
}
