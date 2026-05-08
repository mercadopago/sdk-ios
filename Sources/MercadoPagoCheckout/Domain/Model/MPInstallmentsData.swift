//
//  MPInstallmentsData.swift
//  MercadoPagoSDK
//

struct MPInstallmentsData: Equatable {
    let installment: CardPaymentBrickCardData.Installment
    let cardDisplayInfo: CardDisplayInfo
}

extension MPInstallmentsData {
    static var empty: MPInstallmentsData {
        MPInstallmentsData(
            installment: .init(selectionType: String(), quotas: [], translations: .init(headerTitle: String(), totalLabel: String(), payButtonLabel: String())),
            cardDisplayInfo: .init(issuerName: String(), paymentTypeId: String(), lastFourDigits: String())
        )
    }
}
