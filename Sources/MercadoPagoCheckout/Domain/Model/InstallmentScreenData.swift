//
//  InstallmentScreenData.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 31/08/26.
//

import Foundation

struct InstallmentScreenData: Equatable, Sendable {
    let selectionType: String
    let quotas: [Quota]
    let translations: Translations

    struct Quota: Equatable, Identifiable, Sendable {
        var id: Int {
            self.installments
        }

        let installments: Int
        let installmentAmount: Decimal
        let totalAmount: Decimal
        let primaryLabel: String
        let secondaryLabel: String
        let state: State
        let tertiaryLabel: String?
        let accessibilityLabel: String?
    }

    enum State: Equatable, Sendable {
        case success
        case none

        init(_ rawValue: String) {
            switch rawValue {
            case "success": self = .success
            default: self = .none
            }
        }
    }

    struct Translations: Equatable, Sendable {
        let headerTitle: String
        let totalLabel: String
        let payButtonLabel: String
        let currencySymbol: String
    }
}

extension InstallmentScreenData {
    typealias QuotaState = State
    typealias InstallmentTranslations = Translations
}
