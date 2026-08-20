//
//  ReviewConfirmScreen.swift
//  MercadoPagoSDK
//

import MPComponents
import MPFoundation
import SwiftUI

struct ReviewConfirmScreen: View {
    @Environment(\.checkoutTheme) private var theme: MPTheme

    @ObservedObject private var viewModel: ReviewConfirmViewModel

    @State private var isConfirming = false

    private let onConfirmed: (OrderTransactionProcessData) -> Void
    private let onConfirmError: (MercadoPagoCheckoutError) -> Void
    private let onInitializationError: (MercadoPagoCheckoutError) -> Void
    private let onModifyPaymentMethod: () -> Void
    private let onModifyEmail: (() -> Void)?
    private let onBack: () -> Void

    init(
        viewModel: ReviewConfirmViewModel,
        onConfirmed: @escaping (OrderTransactionProcessData) -> Void = { _ in },
        onConfirmError: @escaping (MercadoPagoCheckoutError) -> Void = { _ in },
        onInitializationError: @escaping (MercadoPagoCheckoutError) -> Void = { _ in },
        onModifyPaymentMethod: @escaping () -> Void = {},
        onModifyEmail: (() -> Void)? = nil,
        onBack: @escaping () -> Void = {}
    ) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onConfirmed = onConfirmed
        self.onConfirmError = onConfirmError
        self.onInitializationError = onInitializationError
        self.onModifyPaymentMethod = onModifyPaymentMethod
        self.onModifyEmail = onModifyEmail
        self.onBack = onBack
    }

    var body: some View {
        self.content
            .background(self.theme.colors.background.primary.edgesIgnoringSafeArea(.all))
            .mpTask {
                await self.viewModel.load()
                if case let .error(error) = self.viewModel.screenState {
                    self.onInitializationError(error)
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch self.viewModel.screenState {
        case .loading:
            self.loadingView
        case let .success(output):
            self.successView(output)
        case .error:
            self.theme.colors.background.primary.edgesIgnoringSafeArea(.all)
        }
    }

    private var loadingView: some View {
        ZStack {
            self.theme.colors.background.primary
                .edgesIgnoringSafeArea(.all)
            MPProgressIndicator()
                .size(.xlarge)
        }
    }

    private func successView(_ output: ReviewConfirmOutput) -> some View {
        MPHeader(
            title: output.header.title,
            onBack: {
                self.viewModel.goBack()
                self.onBack()
            },
            content: {
                VStack(alignment: .leading, spacing: self.theme.spacings.xsmall) {
                    self.sellerView(output.header)
                    self.itemsView(output.items)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, self.theme.spacings.xtiny)
            },
            footer: { self.footerBlock(summary: output.footerSummary, footer: output.footer) }
        )
    }

    // MARK: - Header seller

    @ViewBuilder
    private func sellerView(_ header: ReviewConfirmHeader) -> some View {
        if header.sellerName != nil || header.sellerIconUrl != nil {
            VStack(alignment: .leading, spacing: self.theme.spacings.xmicro) {
                if let iconUrl = header.sellerIconUrl, let url = URL(string: iconUrl) {
                    MPIcon(source: .remote(url: url))
                        .mpIconStyle(.thumbnailCircle)
                }
                if let name = header.sellerName {
                    Text(name)
                        .textStyle(.headingSmall())
                }
            }
        }
    }

    // MARK: - Data rows

    private func itemsView(_ items: [ReviewConfirmItem]) -> some View {
        VStack(alignment: .leading, spacing: self.theme.spacings.xsmall) {
            ForEach(items.indices, id: \.self) { index in
                self.row(for: items[index])
            }
        }
        .listItemStyle(.compact)
    }

    private func row(for item: ReviewConfirmItem) -> some View {
        switch item.type {
        case "payment_method":
            self.dataRow(item, onModify: self.onModifyPaymentMethod)
        case "payer_email":
            self.dataRow(item, onModify: self.onModifyEmail)
        default:
            self.dataRow(item, onModify: nil)
        }
    }

    private func dataRow(_ item: ReviewConfirmItem, onModify: (() -> Void)?) -> some View {
        MPListItem(
            contentInfo: .init(title: item.value, header: item.label),
            trailing: onModify.map { MPListItemTrailing(text: item.button?.label, action: $0) }
        )
    }

    // MARK: - Footer (summary breakdown + total + confirm)

    private func footerBlock(summary: ReviewConfirmFooterSummary?, footer: ReviewConfirmFooter) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if self.hasBreakdown(summary) {
                self.summaryBreakdown(summary)
                    .padding(.horizontal, self.theme.spacings.xtiny)
                    .padding(.top, self.theme.spacings.xtiny)
                Rectangle()
                    .fill(self.theme.colors.border.primary)
                    .frame(height: self.theme.borderWidth.small)
                    .padding(.horizontal, self.theme.spacings.xtiny)
                    .padding(.top, self.theme.spacings.xtiny)
            }
            MPFooter(
                title: footer.totalLabel ?? MPStrings.Common.total,
                amount: MPAmountData(
                    from: footer.totalAmount,
                    currencySymbol: footer.currencySymbol ?? MPStrings.Common.currency
                ),
                subtitleData: self.viewModel.installmentsSubtitleData(footer.installments),
                buttonData: .init(
                    text: footer.button.label,
                    icon: .padlockClose,
                    onClick: { await self.handleConfirm() }
                )
            )
            .isLoading(self.isConfirming)
        }
        .background(self.theme.colors.background.primary)
    }

    private func hasBreakdown(_ summary: ReviewConfirmFooterSummary?) -> Bool {
        (summary?.products?.isEmpty == false) || summary?.coupon != nil || summary?.interest != nil
    }

    private func summaryBreakdown(_ summary: ReviewConfirmFooterSummary?) -> some View {
        let products = summary?.products ?? []

        return VStack(alignment: .leading, spacing: self.theme.spacings.xnano) {
            ForEach(products.indices, id: \.self) { index in
                let line = products[index]
                self.summaryLine(label: line.label, amount: line.amount, amountColor: .secondary)
            }
            if let coupon = summary?.coupon {
                self.summaryLine(label: coupon.label, amount: coupon.amount, amountColor: .feedbackPositive)
            }
            if let interest = summary?.interest {
                self.summaryLine(label: interest.title, amount: interest.amount, amountColor: .secondary)
            }
        }
    }

    private func summaryLine(label: String, amount: String, amountColor: TextStyleColorType) -> some View {
        HStack {
            Text(label)
                .textStyle(.smallMedium(colorType: .secondary))
            Spacer()
            Text(amount)
                .textStyle(.smallMedium(colorType: amountColor))
        }
    }

    private func handleConfirm() async {
        guard !self.isConfirming else { return }
        self.isConfirming = true
        defer { self.isConfirming = false }
        do {
            let processData = try await self.viewModel.confirm()
            self.onConfirmed(processData)
        } catch {
            self.onConfirmError(error)
        }
    }
}

#if DEBUG
    /// Feeds the preview a canned backend response so the success layout renders from the real
    /// `load()` in `.mpTask`, without hitting the network.
    private struct PreviewReviewConfirmRepository: ReviewConfirmRepository {
        let json: String

        func fetchReviewConfirm(
            request _: ReviewConfirmRequestBody,
            clientToken _: String
        ) async throws -> ReviewConfirmResponse {
            try JSONDecoder().decode(ReviewConfirmResponse.self, from: Data(self.json.utf8))
        }
    }

    @MainActor
    private func previewReviewConfirmScreen(json: String) -> some View {
        ReviewConfirmScreen(
            viewModel: ReviewConfirmViewModel(
                fetchReviewConfirmUseCase: FetchReviewConfirmUseCase(
                    repository: PreviewReviewConfirmRepository(json: json)
                ),
                order: MPOrder(orderId: "preview", clientToken: "preview"),
                paymentParams: OrderTransactionParams(
                    amount: 188_000,
                    paymentMethodType: .ticket(paymentMethodId: "rapipago")
                ),
                reviewConfirmConfig: .reviewAndConfirm(seller: nil, onPaymentMethodChangeRequested: {}, onEmailChangeRequested: {}),
                cardDetails: .init(bin: nil, issuerId: nil, lastFourDigits: nil, installmentAmount: nil)
            ),
            onModifyPaymentMethod: {},
            onModifyEmail: {}
        )
        .loadMPFonts()
    }

    private let previewSellerIcon =
        "https://http2.mlstatic.com/storage/mobile-on-demand-resources/image/cho_off-rapipago_mdpi"

    #Preview("Card — con resumen y descripción") {
        previewReviewConfirmScreen(
            json: """
            {
              "header": {
                "title": "Revisá los datos antes de pagar",
                "seller_name": "Adidas Originals",
                "seller_icon_url": "\(previewSellerIcon)"
              },
              "items": [
                {
                  "type": "payment_method",
                  "label": "Medio de pago",
                  "value": "Santander Crédito •••• 1234",
                  "button": { "label": "Modificar" }
                }
              ],
              "footer_summary": {
                "products": [
                  { "label": "Adidas Samba", "amount": "$ 5.500" }
                ],
                "coupon": { "label": "ADI500", "amount": "- $ 500" }
              },
              "footer": {
                "button": { "label": "Pagar" },
                "total_amount": 5000,
                "currency_symbol": "$",
                "installments": {
                  "label": "3x $ 1.666,66",
                  "secondary_label": "sin interés",
                  "state": "success"
                }
              }
            }
            """
        )
    }
#endif
