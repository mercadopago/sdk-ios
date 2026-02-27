//
//  CardFormBrick.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 14/11/25.
//
import SwiftUI
import MPComponents
import CoreMethods

struct CardFormScreen: View {
    
    private let onBack: () -> Void
    private let onContinue: () -> Void
    
    @ObservedObject private var viewModel: CardFormViewModel
    
    // MARK: States View
    @State private var cardForm = CardFormData()
    @State private var openDocumentsSheet: Bool = false
    @Binding private var paymentData: MPPaymentData

    // MARK: Enviroments
    @Environment(\.checkoutTheme) var theme: MPTheme

    init(
        paymentData: Binding<MPPaymentData>,
        viewModel: CardFormViewModel,
        onBack: @escaping () -> Void = {},
        onContinue: @escaping () -> Void = {}
    ) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onBack = onBack
        self.onContinue = onContinue
        self._paymentData = paymentData
    }

    var body: some View {
        Group {
            switch viewModel.screenState {
            case .loading:
                MPProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(theme.colors.background.primary)
            case .ready:
                MPHeader(
                    title: MPStrings.CardForm.title,
                    onBack: { onBack() },
                    footer: {
                        MPFooter(
                            label: MPStrings.Common.total,
                            amount: MPStrings.formatPrice(paymentData.transactionAmount),
                            buttonLabel: MPStrings.CardForm.button,
                            action: { onContinue() }
                        )
                        .disabled(!cardForm.isFormValid)
                    },
                    content: {
                        VStack(spacing: theme.spacings.xsmall) {
                            MPTextField(
                                text: $cardForm.cardNumber,
                                label: MPStrings.CardForm.CardNumber.label,
                                placeholder: MPStrings.CardForm.CardNumber.placeholder,
                                errorMessage: cardForm.$cardNumber,
                                externalError: cardForm.cardNumberExternalError,
                                keyboard: .numberPad,
                                formatter: viewModel.cardNumberFormatter,
                            )

                            MPTextField(
                                text: $cardForm.cardHolder,
                                label: MPStrings.CardForm.CardHolder.label,
                                placeholder: MPStrings.CardForm.CardHolder.placeholder,
                                helperText: MPStrings.CardForm.CardHolder.helperText,
                                errorMessage: cardForm.$cardHolder,
                            )

                            MPTextField(
                                text: $cardForm.expirationDate,
                                label: MPStrings.CardForm.Expiration.label,
                                placeholder: MPStrings.CardForm.Expiration.placeholder,
                                errorMessage: cardForm.$expirationDate,
                                keyboard: .numberPad,
                                formatter: viewModel.expirationDateFormatter,
                            )

                            MPTextField(
                                text: $cardForm.securityCode,
                                label: MPStrings.CardForm.CVV.label,
                                placeholder: MPStrings.CardForm.CVV.placeholderDefault,
                                errorMessage: cardForm.$securityCode,
                                keyboard: .numberPad,
                                formatter: viewModel.securityCodeFormatter,
                                popoverText: MPStrings.CardForm.CVV.tooltipStaticDefault
                            )

                            MPTextField(
                                text: $cardForm.documentHolder,
                                label: MPStrings.CardForm.Document.label,
                                placeholder: viewModel.selectTypeDocument?.getPlaceholder(),
                                errorMessage: cardForm.$documentHolder,
                                keyboard: viewModel.selectTypeDocument?.getKeyboardType() ?? .default,
                                formatter: viewModel.documentFormatter,
                                prefix: {
                                    dropdownDocument()
                                },
                            )
                        }
                        .padding(.horizontal, theme.spacings.micro)
                    }
                )
                .background(theme.colors.background.primary)
            }
        }
        .mpTask {
            await viewModel.loadIdentificationTypes()
        }
        .mpOnChange(of: cardForm.cardNumber) { newValue in
            viewModel.onCardNumberChange(newValue)
        }
        .mpOnChange(of: viewModel.hasCardNumberApiError) { hasError in
            cardForm.setCardNumberApiError(hasError)
        }
    }
        
    @ViewBuilder
    func dropdownDocument() -> some View {
        Button {
            openDocumentsSheet.toggle()
        } label: {
            HStack {
                Text(viewModel.selectTypeDocument?.name ?? String())
                    .textStyle(.bodyMedium(colorType: .secondary))
                
                Image(systemName: openDocumentsSheet ? "chevron.up" : "chevron.down")
                    .renderingMode(.template)
                    .foregroundColor(theme.textFields.standard.idle.borderColor)
                    .padding(.horizontal, theme.spacings.xmicro)
            }
            .frame(maxHeight: .infinity)
            .overlay(
                Rectangle()
                    .frame(width: theme.borderWidth.small)
                    .foregroundColor(theme.textFields.standard.idle.borderColor),
                alignment: .trailing
            )
            .padding(.leading, theme.spacings.micro)
        }
        .accessibility(label: Text(verbatim: viewModel.selectTypeDocument?.name ?? String()))
    }
}

struct CardForm_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ThemeProvider(
            light: MPLightTheme(),
            dark: MPLightTheme()
        ) {
            CardFormScreen(
                paymentData: .constant(MPPaymentData(transactionAmount: 100)),
                viewModel: .init(
                    configuration: .init(
                        type: .cardForm(cardFormConfiguration: .init()),
                        paymentMethod: []
                    )
                )
            )
        }

    }
}
