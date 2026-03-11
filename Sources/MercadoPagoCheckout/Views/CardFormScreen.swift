//
//  CardFormBrick.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 14/11/25.
//
import CoreMethods
import MPComponents
import SwiftUI

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
            switch self.viewModel.screenState {
            case .loading:
                MPProgressIndicator()
                    .size(.xlarge)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .ready:
                MPHeader(
                    title: MPStrings.CardForm.title,
                    onBack: { self.onBack() },
                    footer: {
                        MPFooter(
                            label: MPStrings.Common.total,
                            amount: MPStrings.formatPrice(self.paymentData.transactionAmount),
                            buttonLabel: MPStrings.CardForm.button,
                            action: { self.onContinue() }
                        )
                        .disabled(!self.cardForm.isFormValid(isSecurityCodeMandatory: self.viewModel.isSecurityCodeMandatory))
                        .background(
                            GeometryReader { geo in
                                Color.clear.onAppear { self.footerHeight = geo.size.height }
                            }
                        )
                    },
                    content: {
                        VStack(spacing: self.theme.spacings.xsmall) {
                            MPTextField(
                                text: self.$cardForm.cardNumber,
                                label: MPStrings.CardForm.CardNumber.label,
                                placeholder: MPStrings.CardForm.CardNumber.placeholder,
                                errorMessage: self.cardForm.$cardNumber,
                                liveErrorMessage: self.cardForm.cardNumberLiveErrors,
                                keyboard: .numberPad,
                                onEditingChanged: { isEditing in
                                    if !isEditing { self.viewModel.retryBinFetch() }
                                },
                                formatter: self.viewModel.cardNumberFormatter
                            )

                            MPTextField(
                                text: self.$cardForm.cardHolder,
                                label: MPStrings.CardForm.CardHolder.label,
                                placeholder: MPStrings.CardForm.CardHolder.placeholder,
                                helperText: MPStrings.CardForm.CardHolder.helperText,
                                errorMessage: self.cardForm.$cardHolder
                            )

                            MPTextField(
                                text: self.$cardForm.expirationDate,
                                label: MPStrings.CardForm.Expiration.label,
                                placeholder: MPStrings.CardForm.Expiration.placeholder,
                                errorMessage: self.cardForm.$expirationDate,
                                keyboard: .numberPad,
                                formatter: self.viewModel.expirationDateFormatter
                            )

                            if self.viewModel.isSecurityCodeMandatory {
                                MPTextField(
                                    text: self.$cardForm.securityCode,
                                    label: MPStrings.CardForm.CVV.label,
                                    placeholder: self.viewModel.cvvPlaceholder,
                                    errorMessage: self.cardForm.$securityCode,
                                    keyboard: .numberPad,
                                    formatter: self.viewModel.securityCodeFormatter,
                                    popoverText: self.viewModel.cvvTooltipText
                                )
                            }

                            MPTextField(
                                text: self.$cardForm.documentHolder,
                                label: MPStrings.CardForm.Document.label,
                                placeholder: self.viewModel.selectTypeDocument?.getPlaceholder(),
                                errorMessage: self.cardForm.$documentHolder,
                                keyboard: self.viewModel.selectTypeDocument?.getKeyboardType() ?? .default,
                                formatter: self.viewModel.documentFormatter,
                                prefix: {
                                    self.dropdownDocument()
                                }
                            )
                        }
                        .padding(.horizontal, self.theme.spacings.micro)
                    }
                )
            }
        }
        .messageSnackbar(
            isPresented: self.$isSnackbarPresented,
            text: MPStrings.Errors.generic,
            state: .negative,
            bottomPadding: self.footerHeight
        )
        .background(self.theme.colors.background.primary.edgesIgnoringSafeArea(.all))
        .mpTask {
            await self.viewModel.loadIdentificationTypes()
        }
        .mpOnChange(of: self.cardForm.cardNumber) { newValue in
            self.viewModel.onCardNumberChange(newValue)
        }
        .mpOnChange(of: self.viewModel.binData) { binData in
            self.updateCardNumberLength(binData: binData)
        }
        .mpOnChange(of: self.viewModel.selectTypeDocument) { identificationType in
            self.updateIdentificationTypes(identificationType)
        }
        .mpOnChange(of: self.viewModel.binFetchError) { error in
            self.cardForm.setCardNumberExternalError(error)
        }
        .mpOnChange(of: self.viewModel.showSnackbar) { show in
            if show { self.isSnackbarPresented = true }
        }
    }

    private func dropdownDocument() -> some View {
        HStack(spacing: 0) {
            if #available(iOS 14.0, *) {
                self.documentPickerMenu()
            } else {
                self.documentPickerFallback()
            }

            Rectangle()
                .fill(self.theme.textFields.standard.idle.borderColor)
                .frame(width: self.theme.borderWidth.small)
        }
    }

    @available(iOS 14.0, *)
    private func documentPickerMenu() -> some View {
        Menu {
            Picker(
                selection: self.$viewModel.selectTypeDocument,
                label: EmptyView()
            ) {
                ForEach(self.viewModel.identificationTypes, id: \.id) { type in
                    Text(type.name).tag(Optional(type))
                }
            }
        } label: {
            self.documentLabel()
        }
        .accessibility(label: Text(verbatim: self.viewModel.selectTypeDocument?.name ?? String()))
    }

    private func documentPickerFallback() -> some View {
        Picker(
            selection: self.$viewModel.selectTypeDocument,
            label: self.documentLabel()
        ) {
            ForEach(self.viewModel.identificationTypes, id: \.id) { type in
                Text(type.name).tag(Optional(type))
            }
        }
        .fixedSize(horizontal: true, vertical: false)
        .accentColor(self.theme.textFields.standard.idle.textColor)
        .accessibility(label: Text(verbatim: self.viewModel.selectTypeDocument?.name ?? String()))
    }

    private func documentLabel() -> some View {
        HStack {
            Text(self.viewModel.selectTypeDocument?.name ?? String())
                .textStyle(.bodyMedium(colorType: .secondary))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)

            Image(systemName: "chevron.down")
                .renderingMode(.template)
                .foregroundColor(self.theme.textFields.standard.idle.borderColor)
                .padding(.horizontal, self.theme.spacings.xmicro)
        }
        .padding(.leading, self.theme.spacings.micro)
        .animation(nil)
    }

    private func updateCardNumberLength(binData: CardBinData?) {
        if let cardInfo = binData?.paymentMethod.card {
            self.cardForm.setCardNumberLength(cardInfo.length.min, cardInfo.length.max)
            self.cardForm.setSecurityCodeLength(cardInfo.securityCode.length)
        } else {
            self.cardForm.setCardNumberLength()
        }
    }

    private func updateIdentificationTypes(_ identificationType: IdentificationType?) {
        guard let identificationType else { return }
        self.cardForm.setDocumentLength(identificationType.minLenght, identificationType.maxLenght)
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
