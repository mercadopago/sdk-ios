//
//  CardPaymentBrickCardData.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 13/04/26.
//

struct CardPaymentBrickCardData: Equatable {
    let securityCodeTranslations: SecurityCodeTranslations?
    let installment: Installment?
    let paymentMethods: [PaymentMethod]

    // MARK: - SecurityCodeTranslations

    struct SecurityCodeTranslations: Equatable {
        let label: String
        let placeholder: String
        let helper: String
        let tooltip: String
        let errorEmpty: String
        let errorIncomplete: String
        let errorInvalid: String
    }

    // MARK: - Installment

    struct Installment: Equatable {
        let selectionType: String
        let quotas: [Quota]

        struct Quota: Equatable {
            let installments: Int
            let installmentAmount: Double
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
        }

        struct Issuer: Equatable {
            let id: String
            let name: String
        }
    }
}
