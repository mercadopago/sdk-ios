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
    private let onBack: (MPCancelledFormContext) -> Void
    private let onSuccess: (MPPaymentData) -> Void
    private let onFailure: (MercadoPagoCheckoutError) -> Void
    private let transactionAmount: Double?

    @ObservedObject private var viewModel: CardFormViewModel
    private let initResult: CardFormInitializationOutput

    // MARK: States View

    @State private var cardForm: CardFormData
    @State private var isSnackbarPresented = false
    @State private var footerHeight: CGFloat = 0

    // MARK: Enviroments

    @Environment(\.checkoutTheme) var theme: MPTheme

    init(
        initResult: CardFormInitializationOutput,
        transactionAmount: Double?,
        viewModel: CardFormViewModel,
        onBack: @escaping (MPCancelledFormContext) -> Void = { _ in },
        onSuccess: @escaping (MPPaymentData) -> Void = { _ in },
        onFailure: @escaping (MercadoPagoCheckoutError) -> Void = { _ in }
    ) {
        self.initResult = initResult
        self._cardForm = State(initialValue: CardFormData(fields: initResult.fields))
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onBack = onBack
        self.onSuccess = onSuccess
        self.onFailure = onFailure
        self.transactionAmount = transactionAmount
    }

    var body: some View {
        MPHeader(
            title: self.initResult.title,
            onBack: { self.onBack(self.cardForm.cancelledFormContext) },
            footer: {
                MPFooter(
                    title: MPStrings.Common.total,
                    amount: self.viewModel.footerAmount(),
                    buttonData: .init(
                        text: MPStrings.CardForm.button,
                        onClick: {
                            await self.viewModel.submitCardData(
                                cardForm: self.cardForm,
                                transactionAmount: self.transactionAmount,
                                onSuccess: { self.onSuccess($0) },
                                onFailure: { self.onFailure($0) }
                            )
                        }
                    )
                )
                .isLoading(self.viewModel.isTokenizing)
                .disabled(
                    !self.cardForm.isFormValid(
                        isSecurityCodeMandatory: self.viewModel.isSecurityCodeMandatory,
                        isDocumentRequired: self.viewModel.requiresIdentificationTypes
                    )
                )
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
                        label: self.initResult.fields.cardNumber.label,
                        placeholder: self.initResult.fields.cardNumber.placeholder,
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
                        label: self.initResult.fields.cardHolder.label,
                        placeholder: self.initResult.fields.cardHolder.placeholder,
                        helperText: self.initResult.fields.cardHolder.helperText,
                        errorMessage: self.cardForm.$cardHolder
                    )

                    MPTextField(
                        text: self.$cardForm.expirationDate,
                        label: self.initResult.fields.expiration.label,
                        placeholder: self.initResult.fields.expiration.placeholder,
                        errorMessage: self.cardForm.$expirationDate,
                        keyboard: .numberPad,
                        formatter: self.viewModel.expirationDateFormatter
                    )

                    if self.viewModel.isSecurityCodeMandatory {
                        MPTextField(
                            text: self.$cardForm.securityCode,
                            label: self.initResult.fields.cvv.label,
                            placeholder: self.viewModel.cvvPlaceholder,
                            errorMessage: self.cardForm.$securityCode,
                            keyboard: .numberPad,
                            formatter: self.viewModel.securityCodeFormatter,
                            popoverText: self.viewModel.cvvTooltipText
                        )
                    }

                    if self.viewModel.requiresIdentificationTypes {
                        MPTextField(
                            text: self.$cardForm.documentHolder,
                            label: self.initResult.fields.document.label,
                            placeholder: self.viewModel.selectTypeDocument?.getPlaceholder(),
                            errorMessage: self.cardForm.$documentHolder,
                            keyboard: self.viewModel.selectTypeDocument?.getKeyboardType() ?? .default,
                            formatter: self.viewModel.documentFormatter,
                            prefix: {
                                self.dropdownDocument()
                            }
                        )
                    }
                }
                .padding(.horizontal, self.theme.spacings.micro)
            }
        )
        .messageSnackbar(
            isPresented: self.$isSnackbarPresented,
            text: MPStrings.Errors.generic,
            state: .negative,
            bottomPadding: self.footerHeight
        )
        .background(self.theme.colors.background.primary.edgesIgnoringSafeArea(.all))
        .mpOnChange(of: self.cardForm.cardNumber) { newValue in
            self.viewModel.onCardNumberChange(newValue)
        }
        .mpOnChange(of: self.viewModel.binData) { binData in
            self.updateCardNumberLength(binData: binData)
        }
        .mpOnChange(of: self.viewModel.selectTypeDocument) { identificationType in
            self.updateIdentificationTypes(identificationType)
        }
        .mpOnChange(of: self.viewModel.cardAcceptanceError) { error in
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
            self.cardForm.cleanSecurityCodeField()
        }
    }

    private func updateIdentificationTypes(_ identificationType: IdentificationType?) {
        guard let identificationType else { return }
        self.cardForm.setDocumentLength(identificationType.minLenght, identificationType.maxLenght)
    }
}
