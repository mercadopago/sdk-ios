//
//  CardToken.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 18/02/25.
//

public struct CardToken: Sendable, Equatable {
    /// The secure token representing the card, generated after successful tokenization
    public let token: String
    /// This app public Key
    public let publicKey: String?
    /// First card eight digits
    public let bin: String?
    /// Card expiration Month
    public let expirationMonth: Int?
    /// Card expiration year
    public let expirationYear: Int?
    /// Last four digits of the card
    public let lastFourDigits: String?
    /// Card holder
    public let cardHolder: CardHolder?
    /// Card status
    public let status: String?
    /// Date of creation of this token
    public let dateCreated: String?
    /// Date of creation of this token
    public let dateLastUpdated: String?
    /// Date of creation of this token
    public let dateDue: String?
    /// Card number has passed luhn Validation
    public let luhnValidation: Bool?
    /// This is live mode
    public let liveMode: Bool?
    /// This require esc
    public let requireEsc: Bool?
    /// Card number length
    public let cardNumberLength: Int?
    /// Card security code length
    public let securityCodeLength: Int?
    /// Thunc Card Number
    public let truncCardNumber: String?
}

public struct CardHolder: Sendable, Equatable {
    /// Card holder identification
    public let identification: Identification?
    /// Card holder name
    public let name: String?
}

public struct Identification: Sendable, Equatable {
    /// Identification type
    public let type: String?
}
