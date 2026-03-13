//
//  CardFormBrickError.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 30/01/26.
//
import Foundation

@frozen
public struct MercadoPagoCheckoutError: Error, LocalizedError, CustomDebugStringConvertible, CustomNSError {
    public struct Code: RawRepresentable, Equatable, Hashable, Sendable {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let networkConnectionFailed = Code(rawValue: -1009)
        public static let networkTimeout = Code(rawValue: -1001)
        public static let serviceError = Code(rawValue: 2000)
        public static let unknown = Code(rawValue: 999)
        public static let invalidConfiguration = Code(rawValue: 10010)
    }

    public enum LocationDescription: String, CaseIterable, Equatable {
        case cardForm
        case tokenization
        case identification
        case paymentMethods
        case installments
        case issuer
    }

    public let code: Code
    private let _localizedDescription: String
    private let _userInfo: [String: Any]
    private let _location: LocationDescription

    init(code: Code, _localizedDescription: String, _userInfo: [String: Any] = [:], location: LocationDescription) {
        self.code = code
        self._localizedDescription = _localizedDescription
        self._userInfo = _userInfo
        self._location = location
    }

    public var errorDescription: String? {
        self._localizedDescription
    }

    public var locationDescription: String {
        self._location.rawValue
    }

    public var debugDescription: String {
        "\(#file):\(#line): MercadoPagoCheckoutError(code: \(self.code.rawValue), location: \(self._location.rawValue), description: \(self._localizedDescription))"
    }

    public static let errorDomain = "MercadoPagoSDK"
    public var errorCode: Int {
        self.code.rawValue
    }

    public var errorUserInfo: [String: Any] {
        self._userInfo
    }
}
