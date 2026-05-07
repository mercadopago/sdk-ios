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

struct InstallmentScreen: View {
    @Environment(\.checkoutTheme) var theme: MPTheme
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject private var viewModel: InstallmentsScreenViewModel
    @State var selectedPayerCost: Installment.PayerCost?

    private let interactionMode: InteractionMode
    private let onBack: () -> Void
    private let onContinue: () -> Void
    @Binding private var paymentData: MPPaymentData

    init(
        paymentData: Binding<MPPaymentData>,
        installments: Installment,
        interactionMode: InteractionMode = .radioButton,
        onBack: @escaping () -> Void,
        onContinue: @escaping () -> Void = {}
    ) {
        self._paymentData = paymentData
        self.viewModel = InstallmentsScreenViewModel(installments: installments)
        self.interactionMode = interactionMode
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

    @ViewBuilder
    private func listItem(for payerCost: Installment.PayerCost) -> some View {
        let listItem = MPListItem(
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

        switch self.interactionMode {
        case .radioButton:
            listItem
                .listItemStyle(.radioButton)
        case .chevron:
            listItem
                .listItemStyle(.chevron)
                .listItemTrailingStyle(.textIcon(Image(systemName: "chevron.right")))
        }
    }

    private var footer: some View {
        MPFooter(
            title: MPStrings.Common.total,
            amount: self.viewModel.selectedTotalAmount(self.selectedPayerCost),
            subtitle: self.viewModel.formatFooterDescription(),
            buttonData: self.interactionMode == .radioButton ? .init(
                text: "text",
                icon: .padlockClose,
                onClick: {
                    self.onContinue()
                }
            ) : nil
        )
    }

    // MARK: - Helper Methods

    private func bindingForPayerCost(_ payerCost: Installment.PayerCost) -> Binding<Bool> {
        switch self.interactionMode {
        case .radioButton:
            return Binding(
                get: { self.selectedPayerCost == payerCost },
                set: { if $0 { self.selectedPayerCost = payerCost } }
            )
        case .chevron:
            return Binding(
                get: { false },
                set: { if $0 { self.onContinue() } }
            )
        }
    }
}

extension InstallmentScreen {
    enum InteractionMode {
        case radioButton
        case chevron
    }
}

#Preview("Radio Button") {
    InstallmentScreen(
        paymentData: .constant(
            MPPaymentData(transactionAmount: 100)
        ),
        installments: InstallmentMock.visa,
        interactionMode: .radioButton,
        onBack: {}
    )
}

#Preview("Chevron") {
    InstallmentScreen(
        paymentData: .constant(
            MPPaymentData(transactionAmount: 100)
        ),
        installments: InstallmentMock.visa,
        interactionMode: .chevron,
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
