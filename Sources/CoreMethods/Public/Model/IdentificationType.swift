//
//  IdentificationType.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 25/02/25.
//
import Foundation

public struct IdentificationType: Sendable, Equatable, Hashable, Codable {
    public let id: String
    public let name: String
    public let type: String
    public let minLength: Int
    public let maxLength: Int

    package let placeholder: String
    package let mask: String
    package let sequence: String?

    public init(id: String, name: String, type: String, minLength: Int, maxLength: Int) {
        self.id = id
        self.name = name
        self.type = type
        self.minLength = minLength
        self.maxLength = maxLength
        self.placeholder = ""
        self.mask = ""
        self.sequence = nil
    }

    public init(name: String) {
        self.id = ""
        self.name = name
        self.type = ""
        self.minLength = 0
        self.maxLength = 0
        self.placeholder = ""
        self.mask = ""
        self.sequence = nil
    }

    package init(
        id: String,
        name: String,
        type: String,
        minLength: Int,
        maxLength: Int,
        placeholder: String,
        mask: String,
        sequence: String? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.minLength = minLength
        self.maxLength = maxLength
        self.placeholder = placeholder
        self.mask = mask
        self.sequence = sequence
    }
}
