//
//  InstallmentScreen.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 14/11/25.
//

import CoreMethods
import MPComponents
import MPFoundation
import SwiftUI

// MARK: - Interaction Style Protocol

protocol InstallmentInteractionStyle {
    var listItemStyle: MPListItemStyle { get }
    var listItemTrailingStyle: MPListItemTrailingStyle? { get }

    func footerButtonData(onContinue: @escaping () -> Void) -> MPFixedFooterButtonData?

    func selectionBinding(
        for payerCost: Installment.PayerCost,
        selected: Binding<Installment.PayerCost?>,
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

    func footerButtonData(onContinue: @escaping () -> Void) -> MPFixedFooterButtonData? {
        .init(text: "text", icon: .padlockClose, onClick: onContinue)
    }

    func selectionBinding(
        for payerCost: Installment.PayerCost,
        selected: Binding<Installment.PayerCost?>,
        onContinue _: @escaping () -> Void
    ) -> Binding<Bool> {
        Binding(
            get: { selected.wrappedValue == payerCost },
            set: { if $0 { selected.wrappedValue = payerCost } }
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

    func footerButtonData(onContinue _: @escaping () -> Void) -> MPFixedFooterButtonData? {
        nil
    }

    func selectionBinding(
        for _: Installment.PayerCost,
        selected _: Binding<Installment.PayerCost?>,
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

extension Installment {
    /// Resolves the interaction style based on the `interactionMode` returned by the backend.
    ///
    /// This computed property reads the `interactionMode` value and returns the appropriate style.
    /// If `interactionMode` is `nil` or unknown, returns the default style (RadioButton).
    ///
    /// Example usage:
    /// ```swift
    /// let installment = Installment(..., interactionMode: "chevron")
    /// let style = installment.resolvedInteractionStyle // ChevronInstallmentStyle
    /// ```
    var resolvedInteractionStyle: any InstallmentInteractionStyle {
        switch self.interactionMode?.lowercased() {
        case "chevron":
            return ChevronInstallmentStyle()
        case "radio_button", nil:
            return RadioButtonInstallmentStyle()
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
    @State var selectedPayerCost: Installment.PayerCost?

    private let style: any InstallmentInteractionStyle
    private let onBack: () -> Void
    private let onContinue: () -> Void
    @Binding private var paymentData: MPPaymentData

    init(
        paymentData: Binding<MPPaymentData>,
        installments: Installment,
        style: (any InstallmentInteractionStyle)? = nil,
        onBack: @escaping () -> Void,
        onContinue: @escaping () -> Void = {}
    ) {
        self._paymentData = paymentData
        self.viewModel = InstallmentsScreenViewModel(installments: installments)
        self.style = style ?? installments.resolvedInteractionStyle
        self.onBack = onBack
        self.onContinue = onContinue
    }

    var body: some View {
        MPHeader(
            title: MPStrings.Installments.title,
            onBack: {
                self.presentationMode.wrappedValue.dismiss()
            },
            content: {
                ForEach(self.viewModel.payerCosts) { payerCost in
                    self.listItem(for: payerCost)
                }
            },
            footer: {
                self.footer
            }
        )
    }

    // MARK: - Computed Properties

    private func listItem(for payerCost: Installment.PayerCost) -> AnyView {
        MPListItem(
            isSelected: self.bindingForPayerCost(payerCost),
            contentInfo: .init(
                title: self.viewModel.formatInstallmentLabel(for: payerCost),
                description: nil
            ),
            trailing: MPListItemTrailing(
                text: self.viewModel.formatInterestLabel(for: payerCost),
                color: self.viewModel.findInterestLabelColor(for: payerCost)
            )
        )
        .listItemStyle(self.style.listItemStyle)
        .listItemTrailingStyleIfPresent(self.style.listItemTrailingStyle)
    }

    private var footer: some View {
        MPFooter(
            title: MPStrings.Common.total,
            amount: self.viewModel.selectedTotalAmount(self.selectedPayerCost),
            subtitle: self.viewModel.formatFooterDescription(),
            buttonData: self.style.footerButtonData(onContinue: self.onContinue)
        )
    }

    // MARK: - Helper Methods

    private func bindingForPayerCost(_ payerCost: Installment.PayerCost) -> Binding<Bool> {
        self.style.selectionBinding(
            for: payerCost,
            selected: self.$selectedPayerCost,
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
        installments: InstallmentMock.visa,
        style: .radioButton,
        onBack: {}
    )
}

#Preview("Chevron") {
    InstallmentScreen(
        paymentData: .constant(
            MPPaymentData(transactionAmount: 100)
        ),
        installments: InstallmentMock.visa,
        style: .chevron,
        onBack: {}
    )
}

#if DEBUG
    enum InstallmentMock {
        static let visa = Installment(
            paymentMethodId: "visa",
            paymentTypeId: "credit_card",
            thumbnail: "https://http2.mlstatic.com/storage/mobile-on-demand-resources/image/cho_off-visa_mdpi",
            issuer: Installment.Issuer(
                id: "25",
                thumbnail: "https://http2.mlstatic.com/storage/mobile-on-demand-resources/image/cho_off-visa_mdpi",
                name: "Tarjeta de crédito Mercado Pago"
            ),
            processingMode: "aggregator",
            merchantAccountId: "",
            payerCosts: [
                Installment.PayerCost(
                    id: 1, installments: 1, installmentAmount: 1000.0, installmentRate: 0.0,
                    installmentRateCollector: ["MERCADOPAGO"], totalAmount: 1000.0,
                    minAllowedAmount: 0.5, maxAllowedAmount: 60000.0,
                    discountRate: 0.0, reimbursementRate: 0.0, labels: [],
                    paymentMethodOptionId: ""
                ),
                Installment.PayerCost(
                    id: 2, installments: 2, installmentAmount: 500, installmentRate: 0,
                    installmentRateCollector: ["MERCADOPAGO"], totalAmount: 1096.4,
                    minAllowedAmount: 10.0, maxAllowedAmount: 60000.0,
                    discountRate: 0.0, reimbursementRate: 0.0, labels: [],
                    paymentMethodOptionId: ""
                ),
                Installment.PayerCost(
                    id: 3, installments: 3, installmentAmount: 370.77, installmentRate: 11.23,
                    installmentRateCollector: ["MERCADOPAGO"], totalAmount: 1112.3,
                    minAllowedAmount: 15.0, maxAllowedAmount: 60000.0,
                    discountRate: 0.0, reimbursementRate: 0.0, labels: [],
                    paymentMethodOptionId: ""
                ),
                Installment.PayerCost(
                    id: 4, installments: 4, installmentAmount: 278.4, installmentRate: 11.36,
                    installmentRateCollector: ["MERCADOPAGO"], totalAmount: 1113.6,
                    minAllowedAmount: 20.0, maxAllowedAmount: 60000.0,
                    discountRate: 0.0, reimbursementRate: 0.0, labels: [],
                    paymentMethodOptionId: ""
                ),
                Installment.PayerCost(
                    id: 5, installments: 5, installmentAmount: 228.62, installmentRate: 14.31,
                    installmentRateCollector: ["MERCADOPAGO"], totalAmount: 1143.1,
                    minAllowedAmount: 25.0, maxAllowedAmount: 60000.0,
                    discountRate: 0.0, reimbursementRate: 0.0, labels: [],
                    paymentMethodOptionId: ""
                )
            ],
            agreements: []
        )
    }
#endif
