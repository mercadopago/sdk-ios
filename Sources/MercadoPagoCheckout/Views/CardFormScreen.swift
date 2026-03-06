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
    @State private var isSnackbarPresented = false
    @State private var footerHeight: CGFloat = 0
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
                MPProgressIndicator()
                    .size(.xlarge)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                        .background(
                            GeometryReader { geo in
                                Color.clear.onAppear { footerHeight = geo.size.height }
                            }
                        )
                    },
                    content: {
                        VStack(spacing: theme.spacings.xsmall) {
                            MPTextField(
                                text: $cardForm.cardNumber,
                                label: MPStrings.CardForm.CardNumber.label,
                                placeholder: MPStrings.CardForm.CardNumber.placeholder,
                                errorMessage: cardForm.$cardNumber,
                                liveErrorMessage: cardForm.cardNumberLiveErrors,
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
                                placeholder: viewModel.cvvPlaceholder,
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
                .messageSnackbar(
                    isPresented: $isSnackbarPresented,
                    text: MPStrings.Errors.generic,
                    state: .negative,
                    bottomPadding: footerHeight
                )
            }
        }
        .background(theme.colors.background.primary.edgesIgnoringSafeArea(.all))
        .mpTask {
            await viewModel.loadIdentificationTypes()
        }
        .mpOnChange(of: cardForm.cardNumber) { newValue in
            viewModel.onCardNumberChange(newValue)
            
        }
        .mpOnChange(of: viewModel.binData) { binData in
            if let cardInfo = binData?.paymentMethod.card {
                cardForm.setCardNumberLength(cardInfo.length.min, cardInfo.length.max)
                cardForm.setSecurityCodeLength(cardInfo.securityCode.length)
            } else {
                cardForm.setCardNumberLength()
            }
        }
        .mpOnChange(of: viewModel.selectTypeDocument) { identificationType in
            if let identificationType {
                cardForm.setDocumentLength(identificationType.minLenght, identificationType.maxLenght)
            }
        }
        .mpOnChange(of: viewModel.fetchBinError) { error in
            cardForm.setCardNumberExternalError(error)
        }
        .mpOnChange(of: viewModel.snackbarError) { error in
            if error != nil { isSnackbarPresented = true }
        }
    }
        
    @ViewBuilder
    private func dropdownDocument() -> some View {
        HStack(spacing: 0) {
            if #available(iOS 14.0, *) {
                documentPickerMenu()
            } else {
                documentPickerFallback()
            }

            Rectangle()
                .fill(theme.textFields.standard.idle.borderColor)
                .frame(width: theme.borderWidth.small)
        }
    }

    @available(iOS 14.0, *)
    @ViewBuilder
    private func documentPickerMenu() -> some View {
        Menu {
            Picker(
                selection: $viewModel.selectTypeDocument,
                label: EmptyView()
            ) {
                ForEach(viewModel.identificationTypes, id: \.id) { type in
                    Text(type.name).tag(Optional(type))
                }
            }
        } label: {
            documentLabel()
        }
        .accessibility(label: Text(verbatim: viewModel.selectTypeDocument?.name ?? String()))
    }

    @ViewBuilder
    private func documentPickerFallback() -> some View {
        Picker(
            selection: $viewModel.selectTypeDocument,
            label: documentLabel()
        ) {
            ForEach(viewModel.identificationTypes, id: \.id) { type in
                Text(type.name).tag(Optional(type))
            }
        }
        .fixedSize(horizontal: true, vertical: false)
        .accentColor(theme.textFields.standard.idle.textColor)
        .accessibility(label: Text(verbatim: viewModel.selectTypeDocument?.name ?? String()))
    }

    @ViewBuilder
    private func documentLabel() -> some View {
        HStack {
            Text(viewModel.selectTypeDocument?.name ?? String())
                .textStyle(.bodyMedium(colorType: .secondary))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)

            Image(systemName: "chevron.down")
                .renderingMode(.template)
                .foregroundColor(theme.textFields.standard.idle.borderColor)
                .padding(.horizontal, theme.spacings.xmicro)
        }
        .padding(.leading, theme.spacings.micro)
        .animation(nil)
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
