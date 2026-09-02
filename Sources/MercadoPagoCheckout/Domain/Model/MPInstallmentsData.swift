//
//  MPInstallmentsData.swift
//  MercadoPagoSDK
//

struct MPInstallmentsData: Equatable, Sendable {
    let installment: InstallmentScreenData
    let cardDisplayInfo: CardDisplayInfo
}

extension MPInstallmentsData {
    static var empty: MPInstallmentsData {
        let translations = InstallmentScreenData.Translations(
            headerTitle: String(), totalLabel: String(), payButtonLabel: String(), currencySymbol: String()
        )
        let installment = InstallmentScreenData(
            selectionType: String(), quotas: [], translations: translations
        )
        return MPInstallmentsData(
            installment: installment,
            cardDisplayInfo: .init(issuerName: String(), paymentTypeId: String(), lastFourDigits: String())
        )
    }
}
