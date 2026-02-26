//
//  MercadoPagoCheckout+CardBrand.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 26/02/26.
//

public extension MercadoPagoCheckout {
    /// Defines the card brand/network accepted during the checkout flow.
    ///
    /// Use predefined brands like `.visa` or `.mastercard`, or create a custom one
    /// with `.custom("brand_id")` for card networks not explicitly listed.
    public enum CardBrand: Sendable {
        /// Visa card network.
        case visa
        /// Mastercard network.
        case mastercard
        /// American Express card network.
        case amex
        /// Elo card network (Brazil).
        case elo
        /// Hipercard network (Brazil).
        case hipercard
        /// Diners Club card network.
        case diners
        /// Discover card network.
        case discover
        /// Japan Credit Bureau card network.
        case jcb
        /// Maestro debit card network.
        case maestro
        /// UnionPay card network (China).
        case unionPay
        /// Cabal card network (Argentina).
        case cabal
        /// Naranja card network (Argentina).
        case naranja
        /// A custom card brand not explicitly listed.
        ///
        /// - Parameter id: The payment method identifier for the card brand.
        case custom(String)

        /// All predefined card brands.
        public static var defaults: [CardBrand] {
            [.visa, .mastercard, .amex, .elo, .hipercard, .diners, .discover, .jcb, .maestro, .unionPay, .cabal, .naranja]
        }
    }
}

extension MercadoPagoCheckout.CardBrand {
    var paymentMethodId: String {
        switch self {
        case .visa:              return "visa"
        case .mastercard:        return "mastercard"
        case .amex:              return "amex"
        case .elo:               return "elo"
        case .hipercard:         return "hipercard"
        case .diners:            return "diners"
        case .discover:          return "discover"
        case .jcb:               return "jcb"
        case .maestro:           return "maestro"
        case .unionPay:          return "unionpay"
        case .cabal:             return "cabal"
        case .naranja:           return "naranja"
        case .custom(let id):    return id
        }
    }
}
