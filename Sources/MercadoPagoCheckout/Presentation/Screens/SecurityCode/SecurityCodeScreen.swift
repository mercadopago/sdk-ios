//
//  SecurityCodeScreen.swift
//  MercadoPagoSDK
//

import MPComponents
import SwiftUI

struct SecurityCodeScreen: View {
    @Environment(\.checkoutTheme) private var theme: MPTheme

    @ObservedObject private var viewModel: SecurityCodeViewModel

    @State private var field: SecurityCodeFieldData

    private let onTokenSuccess: (String) -> Void
    private let onTokenError: () -> Void
    private let onBack: () -> Void

    init(
        viewModel: SecurityCodeViewModel,
        onTokenSuccess: @escaping (String) -> Void = { _ in },
        onTokenError: @escaping () -> Void = {},
        onBack: @escaping () -> Void = {}
    ) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onTokenSuccess = onTokenSuccess
        self.onTokenError = onTokenError
        self.onBack = onBack
        self._field = State(
            initialValue: SecurityCodeFieldData(
                field: viewModel.screenOutput.field,
                length: viewModel.screenOutput.length
            )
        )
    }

    private var cardLeading: MPListItemLeading {
        switch self.viewModel.cardIcon {
        case let .remote(url):
            return .thumbnail(url)
        case let .system(name):
            return .image(Image(systemName: name))
        }
    }

    var body: some View {
        MPHeader(
            title: self.viewModel.screenOutput.headerTitle,
            onBack: {
                self.viewModel.goBack()
                self.onBack()
            },
            content: {
                VStack(spacing: self.theme.spacings.xmicro) {
                    MPListItem(
                        leading: self.cardLeading,
                        contentInfo: .init(
                            title: self.viewModel.cardTitle,
                            description: self.viewModel.cardDescription
                        )
                    )
                    .listItemStyle(.payment)
                    .padding(.horizontal, self.theme.spacings.xnano)

                    MPTextField(
                        text: self.$field.code,
                        label: self.viewModel.screenOutput.field.label,
                        placeholder: self.viewModel.screenOutput.field.placeholder,
                        errorMessage: self.field.$code,
                        keyboard: .numberPad,
                        formatter: self.viewModel.securityCodeFormatter,
                        popoverText: self.viewModel.screenOutput.field.helper
                    )
                    .accessibilityIDPrefix("mp.securityCode.field")
                    .padding(.horizontal, self.theme.spacings.xtiny)
                }
            },
            footer: {
                MPFooter(
                    title: self.viewModel.totalLabel,
                    amount: self.viewModel.amount,
                    buttonData: .init(
                        text: self.viewModel.screenOutput.buttonLabel,
                        onClick: {
                            await self.handleClick()
                        }
                    )
                )
                .isLoading(self.viewModel.isTokenizing)
                .disabled(self.field.code.filter(\.isNumber).count != self.viewModel.screenOutput.length)
            }
        )
        .background(self.theme.colors.background.primary.edgesIgnoringSafeArea(.all))
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onAppear {
            self.viewModel.trackInitialize()
        }
    }

    func handleClick() async {
        do {
            let token = try await self.viewModel.submit(code: self.field.code)
            self.onTokenSuccess(token)
        } catch {
            self.onTokenError()
        }
    }
}

#if DEBUG
    #Preview {
        SecurityCodeScreen(
            viewModel: SecurityCodeViewModel(
                config: .init(
                    screenOutput: SecurityCodeScreenOutput(
                        length: 3,
                        headerTitle: "Ingresá el código de seguridad",
                        field: .init(
                            label: "Código de seguridad",
                            placeholder: "Ej.: 123",
                            helper: "Está en el reverso de tu tarjeta.",
                            error: "Completá este campo."
                        ),
                        buttonLabel: "Continuar"
                    ),
                    item: PaymentInitializationOutput.Item(
                        id: "987654321",
                        title: "Visa •••• 5678",
                        description: "Visa · Débito",
                        icon: .remote(URL(string: "https://http2.mlstatic.com/storage/mobile-on-demand-resources//image/cho_off-visa_xxxhdpi")),
                        route: "saved_card",
                        cardData: .init(
                            paymentMethodId: "master",
                            paymentTypeId: "debit_card",
                            issuerId: 2,
                            securityCodeScreen: nil
                        )
                    ),
                    footer: .init(totalLabel: "Total", totalAmount: "$ 1.500")
                )
            ),
            onTokenSuccess: { token in print("Token: \(token)") },
            onTokenError: { print("error") },
            onBack: { print("voltar") }
        )
    }
#endif
