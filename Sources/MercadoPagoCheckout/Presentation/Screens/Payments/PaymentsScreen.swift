//
//  PaymentsScreen.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 28/05/26.
//
import MPComponents
import MPFoundation
import SwiftUI

struct PaymentsScreen: View {
    @ObservedObject var viewModel: PaymentsViewModel

    private let onBack: () -> Void
    private let onSelect: (PaymentInitializationOutput.Item) -> Void

    @Environment(\.checkoutTheme) private var theme: MPTheme

    init(
        viewModel: PaymentsViewModel,
        onBack: @escaping () -> Void = {},
        onSelect: @escaping (PaymentInitializationOutput.Item) -> Void = { _ in }
    ) {
        self.viewModel = viewModel
        self.onBack = onBack
        self.onSelect = onSelect
    }

    var body: some View {
        MPHeader(
            title: self.viewModel.title,
            onBack: self.onBack,
            content: {
                VStack(alignment: .leading, spacing: self.theme.spacings.micro) {
                    ForEach(self.viewModel.initialization.sections) { section in
                        self.sectionView(section)
                    }
                }
            },
            footer: {
                MPFooter(
                    title: self.viewModel.totalLabel,
                    amount: self.viewModel.amount
                )
            }
        )
    }

    @ViewBuilder
    private func sectionView(_ section: PaymentInitializationOutput.Section) -> some View {
        VStack(alignment: .leading, spacing: self.theme.spacings.xnano) {
            Text(section.title)
                .textStyle(.headingLarge())
                .padding(.horizontal, self.theme.spacings.xtiny)
                .padding(.vertical, self.theme.spacings.xmicro)

            ForEach(section.items) { item in
                MPListItem(
                    isSelected: self.selectionBinding(for: item),
                    leading: self.leading(for: item.icon),
                    contentInfo: .init(title: item.title, description: item.description),
                    trailing: .init(text: "")
                )
                .listItemTrailingStyle(
                    .textIcon(
                        Image(systemName: Logos.chevronRight)
                    )
                )
                .listItemStyle(.payment)
            }
            .padding(.horizontal, self.theme.spacings.xnano)
        }
    }

    private func selectionBinding(for item: PaymentInitializationOutput.Item) -> Binding<Bool> {
        Binding(
            get: { false },
            set: { isSelected in
                if isSelected { self.onSelect(item) }
            }
        )
    }

    private func leading(for icon: PaymentInitializationOutput.Item.Icon) -> MPListItemLeading {
        switch icon {
        case let .remote(url):
            return .thumbnail(url)
        case let .system(name):
            return .image(Image(systemName: name))
        }
    }
}

#if DEBUG
    #Preview {
        PaymentsScreen(
            viewModel: PaymentsViewModel(),
            onBack: {},
            onSelect: { item in print("selected route:", item.route) }
        )
        .loadMPFonts()
    }
#endif
