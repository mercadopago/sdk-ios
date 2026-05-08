//
//  CardPaymentBrickCardData.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 13/04/26.
//

struct CardPaymentBrickCardData: Equatable {
    let securityCodeTranslations: CardFormFields.CVVField?
    let installment: Installment?
    let paymentMethods: [PaymentMethod]

    // MARK: - Installment

    struct Installment: Equatable {
        let selectionType: String
        let quotas: [Quota]
        let translations: InstallmentTranslations

        struct Quota: Equatable, Identifiable {
            var id: Int {
                self.installments
            }

            let installments: Int
            let installmentAmount: Double
            let totalAmount: Double
            let primaryLabel: String
            let secondaryLabel: String
            let state: QuotaState
            let tertiaryLabel: String?
        }

        enum QuotaState: Equatable {
            case success
            case none

            init(_ rawValue: String) {
                switch rawValue {
                case "success": self = .success
                default: self = .none
                }
            }
        }

        struct InstallmentTranslations: Equatable {
            let headerTitle: String
            let interestFreeLabel: String
            let totalLabel: String
        }
    }

    // MARK: - PaymentMethod

    struct PaymentMethod: Equatable {
        let id: String
        let paymentTypeId: String
        let cardNumber: CardNumberInfo
        let securityCode: SecurityCodeInfo?
        let issuers: [Issuer]

        struct CardNumberInfo: Equatable {
            let type: String
            let length: Length
            let mask: String

            struct Length: Equatable {
                let min: Int
                let max: Int
            }
        }

        struct SecurityCodeInfo: Equatable {
            let mode: String
            let length: Int
            let type: String
            let placeholder: String
            let tooltip: String
        }

        struct Issuer: Equatable {
            let id: String
            let name: String
        }
    }
}
