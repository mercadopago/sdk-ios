//
//  CardPaymentBrickCardData.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 13/04/26.
//
import Foundation

struct CardPaymentBrickCardData: Equatable {
    let securityCodeTranslations: CardFormFields.CVVField?
    let installment: InstallmentScreenData?
    let paymentMethods: [PaymentMethod]

    typealias Installment = InstallmentScreenData

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
