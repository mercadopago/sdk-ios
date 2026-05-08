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
        let translations = CardPaymentBrickCardData.Installment.InstallmentTranslations(
            headerTitle: String(), totalLabel: String(), payButtonLabel: String()
        )
        let installment = CardPaymentBrickCardData.Installment(
            selectionType: String(), quotas: [], translations: translations
        )
        return MPInstallmentsData(
            installment: installment,
            cardDisplayInfo: .init(issuerName: String(), paymentTypeId: String(), lastFourDigits: String())
        )
    }
}
