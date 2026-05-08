//
//  InstallmentScreen.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 14/11/25.
//

import MPComponents
import MPFoundation
import SwiftUI

// MARK: - Interaction Style Protocol

protocol InstallmentInteractionStyle {
    var listItemStyle: MPListItemStyle { get }
    var listItemTrailingStyle: MPListItemTrailingStyle? { get }

    func footerButtonData(_ label: String, onContinue: @escaping () -> Void) -> MPFixedFooterButtonData?

    func selectionBinding(
        for quota: CardPaymentBrickCardData.Installment.Quota,
        selected: Binding<CardPaymentBrickCardData.Installment.Quota?>,
        onContinue: @escaping () -> Void
    ) -> Binding<Bool>
}

// MARK: - Concrete Styles

struct RadioButtonInstallmentStyle: InstallmentInteractionStyle {
    var listItemStyle: MPListItemStyle {
        .radioButton
    }

    var listItemTrailingStyle: MPListItemTrailingStyle? {
        nil
    }

    func footerButtonData(_ label: String, onContinue: @escaping () -> Void) -> MPFixedFooterButtonData? {
        .init(text: label, icon: .padlockClose, onClick: onContinue)
    }

    func selectionBinding(
        for quota: CardPaymentBrickCardData.Installment.Quota,
        selected: Binding<CardPaymentBrickCardData.Installment.Quota?>,
        onContinue _: @escaping () -> Void
    ) -> Binding<Bool> {
        Binding(
            get: { selected.wrappedValue == quota },
            set: { if $0 { selected.wrappedValue = quota } }
        )
    }
}

struct ChevronInstallmentStyle: InstallmentInteractionStyle {
    var listItemStyle: MPListItemStyle {
        .chevron
    }

    var listItemTrailingStyle: MPListItemTrailingStyle? {
        .textIcon(Image(systemName: "chevron.right"))
    }

    func footerButtonData(_: String, onContinue _: @escaping () -> Void) -> MPFixedFooterButtonData? {
        nil
    }

    func selectionBinding(
        for _: CardPaymentBrickCardData.Installment.Quota,
        selected _: Binding<CardPaymentBrickCardData.Installment.Quota?>,
        onContinue: @escaping () -> Void
    ) -> Binding<Bool> {
        Binding(
            get: { false },
            set: { if $0 { onContinue() } }
        )
    }
}

// MARK: - Style Convenience Extensions

extension InstallmentInteractionStyle where Self == RadioButtonInstallmentStyle {
    static var radioButton: RadioButtonInstallmentStyle {
        .init()
    }
}

extension InstallmentInteractionStyle where Self == ChevronInstallmentStyle {
    static var chevron: ChevronInstallmentStyle {
        .init()
    }
}

// MARK: - Installment Extension for Style Resolution

extension CardPaymentBrickCardData.Installment {
    var resolvedInteractionStyle: any InstallmentInteractionStyle {
        switch self.selectionType.lowercased() {
        case "chevron":
            return ChevronInstallmentStyle()
        default:
            return RadioButtonInstallmentStyle()
        }
    }
}

// MARK: - InstallmentScreen

/// Helper extension to conditionally apply trailing style
extension View {
    func listItemTrailingStyleIfPresent(_ style: MPListItemTrailingStyle?) -> AnyView {
        if let style {
            return AnyView(self.listItemTrailingStyle(style))
        } else {
            return AnyView(self)
        }
    }
}

struct InstallmentScreen: View {
    @Environment(\.checkoutTheme) var theme: MPTheme
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject private var viewModel: InstallmentsScreenViewModel
    @State var selectedQuota: CardPaymentBrickCardData.Installment.Quota?

    private let style: any InstallmentInteractionStyle
    private let onBack: () -> Void
    private let onContinue: () -> Void
    @Binding private var paymentData: MPPaymentData

    init(
        paymentData: Binding<MPPaymentData>,
        installmentsData: Binding<MPInstallmentsData>,
        style: (any InstallmentInteractionStyle)? = nil,
        onBack: @escaping () -> Void,
        onContinue: @escaping () -> Void = {}
    ) {
        self._paymentData = paymentData
        self.viewModel = InstallmentsScreenViewModel(installmentsData: installmentsData)
        self.style = style ?? installmentsData.wrappedValue.installment.resolvedInteractionStyle
        self.onBack = onBack
        self.onContinue = onContinue
    }

    var body: some View {
        MPHeader(
            title: self.viewModel.headerTitle,
            onBack: {
                self.presentationMode.wrappedValue.dismiss()
            },
            content: {
                ForEach(self.viewModel.quotas) { quota in
                    self.listItem(for: quota)
                }
            },
            footer: {
                self.footer
            }
        )
    }

    // MARK: - Computed Properties

    private func listItem(for quota: CardPaymentBrickCardData.Installment.Quota) -> AnyView {
        MPListItem(
            isSelected: self.bindingForQuota(quota),
            contentInfo: .init(
                title: quota.primaryLabel,
                description: quota.tertiaryLabel
            ),
            trailing: MPListItemTrailing(
                text: quota.secondaryLabel,
                color: self.viewModel.color(for: quota)
            )
        )
        .listItemStyle(self.style.listItemStyle)
        .listItemTrailingStyleIfPresent(self.style.listItemTrailingStyle)
    }

    private var footer: some View {
        MPFooter(
            title: self.viewModel.totalLabel,
            amount: self.viewModel.selectedTotalAmount(self.selectedQuota),
            subtitle: self.viewModel.footerDescription(),
            buttonData: self.style.footerButtonData(self.viewModel.payButtonLabel, onContinue: self.onContinue)
        )
    }

    // MARK: - Helper Methods

    private func bindingForQuota(_ quota: CardPaymentBrickCardData.Installment.Quota) -> Binding<Bool> {
        self.style.selectionBinding(
            for: quota,
            selected: self.$selectedQuota,
            onContinue: self.onContinue
        )
    }
}

// MARK: - Previews

#Preview("Radio Button") {
    InstallmentScreen(
        paymentData: .constant(
            MPPaymentData(transactionAmount: 100)
        ),
        installmentsData: .constant(InstallmentMock.visa),
        style: .radioButton,
        onBack: {}
    )
}

#Preview("Chevron") {
    InstallmentScreen(
        paymentData: .constant(
            MPPaymentData(transactionAmount: 100)
        ),
        installmentsData: .constant(InstallmentMock.visa),
        style: .chevron,
        onBack: {}
    )
}

#if DEBUG
    enum InstallmentMock {
        static let visa = MPInstallmentsData(
            installment: .init(
                selectionType: "radio_button",
                quotas: [
                    .init(
                        installments: 1,
                        installmentAmount: 1000.0,
                        totalAmount: 1000.0,
                        primaryLabel: "1x R$ 1.000,00",
                        secondaryLabel: "À vista",
                        state: .none,
                        tertiaryLabel: nil
                    ),
                    .init(
                        installments: 3,
                        installmentAmount: 333.34,
                        totalAmount: 1000.0,
                        primaryLabel: "3x R$ 333,34",
                        secondaryLabel: "Sem juros",
                        state: .success,
                        tertiaryLabel: nil
                    ),
                    .init(
                        installments: 6,
                        installmentAmount: 175.0,
                        totalAmount: 1050.0,
                        primaryLabel: "6x R$ 175,00",
                        secondaryLabel: "R$ 1.050,00",
                        state: .none,
                        tertiaryLabel: "CFT: 12,5%  TEA: 18,5%"
                    )
                ],
                translations: .init(
                    headerTitle: "Escolha o parcelamento",

                    totalLabel: "Total",
                    payButtonLabel: "Pagar!"
                )
            ),
            cardDisplayInfo: .init(
                issuerName: "Santander",
                paymentTypeId: "credit_card",
                lastFourDigits: "1234"
            )
        )
    }
#endif
