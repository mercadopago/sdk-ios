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

    private let onBack: () -> Void
    private let onContinue: () -> Void
    @Binding private var paymentData: MPPaymentData

    init(
        paymentData: Binding<MPPaymentData>,
        installments: Installment,
        onBack: @escaping () -> Void,
        onContinue: @escaping () -> Void,
    ) {
        self._paymentData = paymentData
        self.viewModel = InstallmentsScreenViewModel(installments: installments)
        self.onBack = onBack
        self.onContinue = onContinue
    }

    var body: some View {
        MPHeader(
            title: MPStrings.Installments.title,
            onBack: {
                presentationMode.wrappedValue.dismiss()
            },
            content: {
                ForEach(viewModel.payerCosts) { payerCost in
                    MPListItem(
                        type: .radioButton(
                            selected: viewModel.isSelected(payerCost, selectedPayerCost: selectedPayerCost)
                        ),
                        contentInfo: .init(
                            title: viewModel.formatInstallmentLabel(for: payerCost),
                            description: nil
                        ),
                        trailing: MPListItemTrailing(
                            text: viewModel.formatInterestLabel(for: payerCost),
                            color: viewModel.findInterestLabelColor(for: payerCost),
                            type: nil
                        ),
                        onClick: {
                            self.selectedPayerCost = payerCost
                        }
                    )
                }
            }
        )
        MPFooter(
            label: MPStrings.Common.total,
            amount: viewModel.selectedTotalAmount(selectedPayerCost),
            description: viewModel.formatFooterDescription()
        )
    }
}

#Preview {
    InstallmentScreen(
        paymentData: .constant(
            MPPaymentData(transactionAmount: 100)
        ),
        installments: InstallmentMock.visa,
        onBack: {},
        onContinue: {}
    )
}

#if DEBUG
enum InstallmentMock {

    static let visa: Installment = Installment(
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
