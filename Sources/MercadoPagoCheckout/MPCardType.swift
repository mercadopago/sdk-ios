//
//  MPCardType.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 20/02/26.
//

/// The card network or product type accepted by a payment method.
public enum MPCardType: Sendable {
    /// A credit card.
    case credit
    /// A debit card.
    case debit
    /// A prepaid card.
    case prepaid

    public static var defaults: [MPCardType] {
        [.credit, .debit, .prepaid]
    }
}

extension MPCardType: Equatable {
    var paymentTypeId: String {
        switch self {
        case .credit: return "credit_card"
        case .debit: return "debit_card"
        case .prepaid: return "prepaid_card"
        }
    }

    init?(paymentTypeId: String?) {
        switch paymentTypeId {
        case "credit_card": self = .credit
        case "debit_card": self = .debit
        case "prepaid_card": self = .prepaid
        default: return nil
        }
    }
}
