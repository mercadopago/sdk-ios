//
//  MethodSelectionScreen.swift
//  MercadoPagoSDK
//

import MPComponents
import SwiftUI

struct MethodSelectionScreen: View {
    @ObservedObject private var viewModel: MethodSelectionViewModel

    @Environment(\.checkoutTheme) private var theme: MPTheme

    init(viewModel: MethodSelectionViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        MPHeader(
            title: self.viewModel.output.headerTitle,
            onBack: { self.viewModel.goBack() },
            content: {
                VStack(alignment: .leading, spacing: self.theme.spacings.xnano) {
                    ForEach(self.viewModel.output.options) { option in
                        self.optionRow(for: option)
                    }
                }
                .padding(.horizontal, self.theme.spacings.xnano)
                .listItemStyle(self.viewModel.listItemStyle)
                .listItemTrailingStyleIfPresent(self.viewModel.trailingStyle)
                .mpThumbnailStyle(.thumbnailCircle)
                .mpListItemAlignment(.center)
            },
            footer: { self.footerView }
        )
        .background(self.theme.colors.background.primary.edgesIgnoringSafeArea(.all))
    }

    private func optionRow(for option: MethodSelectionOutput.Option) -> MPListItem {
        MPListItem(
            isSelected: self.selectionBinding(for: option),
            leading: .thumbnail(URL(string: option.iconUrl)),
            contentInfo: .init(title: option.name, description: option.subtitle),
            trailing: self.viewModel.rowTrailing
        )
    }

    @ViewBuilder
    private var footerView: some View {
        let amount = MPAmountData(fromFormatted: self.viewModel.output.footer.totalAmount)
        if let button = self.viewModel.output.footer.button {
            MPFooter(
                title: self.viewModel.output.footer.totalLabel,
                amount: amount,
                buttonData: .init(
                    text: button.label,
                    onClick: { self.viewModel.confirmSelection() }
                )
            )
            .disabled(!self.viewModel.isCtaEnabled)
        } else {
            MPFooter(
                title: self.viewModel.output.footer.totalLabel,
                amount: amount
            )
        }
    }

    private func selectionBinding(for option: MethodSelectionOutput.Option) -> Binding<Bool> {
        Binding(
            get: { self.viewModel.selectedOptionId == option.id },
            set: { isSelected in
                if isSelected { self.viewModel.selectOption(option.id) }
            }
        )
    }
}

#if DEBUG
    #Preview {
        MethodSelectionScreen(
            viewModel: MethodSelectionViewModel(
                output: MethodSelectionOutput(
                    headerTitle: "¿Cómo querés pagar?",
                    selectionType: .radioButton,
                    footer: .init(
                        totalLabel: "Total",
                        totalAmount: "$ 1.000",
                        button: .init(label: "Generar código de pago")
                    ),
                    options: [
                        .init(id: "rapipago", name: "Rapipago", subtitle: "Hasta 2 días hábiles", iconUrl: "https://http2.mlstatic.com/storage/mobile-on-demand-resources/image/cho_off-rapipago_mdpi"),
                        .init(id: "pago_facil", name: "Pago Fácil", subtitle: "Hasta 2 días hábiles", iconUrl: "https://http2.mlstatic.com/storage/mobile-on-demand-resources/image/cho_off-pagofacil_mdpi?updatedAt=0")
                    ]
                )
            )
        )
        .loadMPFonts()
    }
#endif
