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
    private let onBack: (CardFormUserCancelledContext) -> Void
    private let onDismiss: (CardFormUserCancelledContext) -> Void
    private let onSuccess: (MPPaymentData) -> Void
    private let onFailure: (MercadoPagoCheckoutError) -> Void
    private let transactionAmount: Double?

    @ObservedObject private var viewModel: CardFormViewModel
    private let initResult: CardFormInitializationOutput

    // MARK: States View

    @State private var cardForm: CardFormData
    @State private var isSnackbarPresented = false
    @State private var footerHeight: CGFloat = 0
    @State private var isCardNumberFocused = false
    @State private var didTapBack = false
    @State private var didComplete = false
    @State private var editedFields: Set<CardFormField> = []

    // MARK: Enviroments

    @Environment(\.checkoutTheme) var theme: MPTheme

    init(
        initResult: CardFormInitializationOutput,
        transactionAmount: Double?,
        viewModel: CardFormViewModel,
        onBack: @escaping (CardFormUserCancelledContext) -> Void = { _ in },
        onDismiss: @escaping (CardFormUserCancelledContext) -> Void = { _ in },
        onSuccess: @escaping (MPPaymentData) -> Void = { _ in },
        onFailure: @escaping (MercadoPagoCheckoutError) -> Void = { _ in }
    ) {
        self.onBack = onBack
        self.onDismiss = onDismiss
        self.onSuccess = onSuccess
        self.onFailure = onFailure
        self.transactionAmount = transactionAmount
        self.initResult = initResult

        self._viewModel = ObservedObject(wrappedValue: viewModel)

        var formData = CardFormData(fields: initResult.fields)
        if let firstType = viewModel.selectTypeDocument {
            formData.setDocumentLength(firstType.minLength, firstType.maxLength)
            formData.setDocumentType(isNumeric: firstType.type != "string")
        }
        self._cardForm = State(initialValue: formData)
    }

    var body: some View {
        MPHeader(
            title: self.initResult.title,
            onBack: {
                self.didTapBack = true
                self.onBack(self.cardForm.cancelledFormContext)
            },
            footer: {
                MPFooter(
                    title: MPStrings.Common.total,
                    amount: nil,
                    buttonData: .init(
                        text: self.initResult.button,
                        onClick: {
                            await self.viewModel.submitCardData(
                                cardForm: self.cardForm,
                                transactionAmount: self.transactionAmount,
                                onSuccess: {
                                    self.didComplete = true
                                    self.onSuccess($0)
                                },
                                onFailure: {
                                    self.didComplete = true
                                    self.onFailure($0)
                                }
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
                            if !isEditing, self.editedFields.contains(.cardNumber) || !self.cardForm.$cardNumber.isEmpty {
                                self.viewModel.cardNumberEditingEnded(isValid: self.cardForm.$cardNumber.isEmpty)
                            }
                        },
                        formatter: self.viewModel.cardNumberFormatter
                    )
                    .mpFocused(self.$isCardNumberFocused)

                    MPTextField(
                        text: self.$cardForm.cardHolder,
                        label: self.initResult.fields.cardHolder.label,
                        placeholder: self.initResult.fields.cardHolder.placeholder,
                        helperText: self.initResult.fields.cardHolder.helperText,
                        errorMessage: self.cardForm.$cardHolder,
                        keyboard: self.initResult.fields.cardHolder.config.getKeyboardType(),
                        onEditingChanged: { isEditing in
                            if !isEditing, self.editedFields.contains(.cardHolder) || !self.cardForm.$cardHolder.isEmpty {
                                self.viewModel.trackInputValidation(
                                    field: .cardHolder,
                                    isValid: self.cardForm.$cardHolder.isEmpty
                                )
                            }
                        }
                    )

                    MPTextField(
                        text: self.$cardForm.expirationDate,
                        label: self.initResult.fields.expiration.label,
                        placeholder: self.initResult.fields.expiration.placeholder,
                        errorMessage: self.cardForm.$expirationDate,
                        keyboard: self.initResult.fields.expiration.config.getKeyboardType(),
                        onEditingChanged: { isEditing in
                            if !isEditing, self.editedFields.contains(.expirationDate) || !self.cardForm.$expirationDate.isEmpty {
                                self.viewModel.trackInputValidation(
                                    field: .expirationDate,
                                    isValid: self.cardForm.$expirationDate.isEmpty
                                )
                            }
                        },
                        formatter: self.viewModel.expirationDateFormatter
                    )

                    if self.viewModel.isSecurityCodeMandatory {
                        MPTextField(
                            text: self.$cardForm.securityCode,
                            label: self.initResult.fields.cvv.label,
                            placeholder: self.viewModel.cvvPlaceholder,
                            errorMessage: self.cardForm.$securityCode,
                            keyboard: self.initResult.fields.expiration.config.getKeyboardType(),
                            onEditingChanged: { isEditing in
                                if !isEditing, self.editedFields.contains(.securityCode) || !self.cardForm.$securityCode.isEmpty {
                                    self.viewModel.trackInputValidation(
                                        field: .securityCode,
                                        isValid: self.cardForm.$securityCode.isEmpty
                                    )
                                }
                            },
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
                            liveErrorMessage: self.cardForm.documentHolderLiveErrors,
                            keyboard: self.viewModel.selectTypeDocument?.getKeyboardType() ?? .default,
                            onEditingChanged: { isEditing in
                                if !isEditing, self.editedFields.contains(.document) || !self.cardForm.$documentHolder.isEmpty {
                                    self.viewModel.trackInputValidation(
                                        field: .document,
                                        isValid: self.cardForm.$documentHolder.isEmpty
                                    )
                                    self.viewModel.trackDropdownSelection(selectedValue: self.viewModel.selectTypeDocument?.id ?? "")
                                }
                            },
                            formatter: self.viewModel.documentFormatter,
                            prefix: {
                                self.dropdownDocument()
                            }
                        )
                        .id(self.viewModel.selectTypeDocument?.getKeyboardType() ?? .default)
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
        .onAppear {
            self.isCardNumberFocused = true
        }
        .mpOnChange(of: self.cardForm.cardNumber) { newValue in
            self.editedFields.insert(.cardNumber)
            self.viewModel.onCardNumberChange(newValue)
        }
        .mpOnChange(of: self.viewModel.cardData) { cardData in
            self.updateCardNumberLength(cardData: cardData)
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
        .mpOnChange(of: self.cardForm.cardHolder) { _ in self.editedFields.insert(.cardHolder) }
        .mpOnChange(of: self.cardForm.expirationDate) { _ in self.editedFields.insert(.expirationDate) }
        .mpOnChange(of: self.cardForm.securityCode) { _ in self.editedFields.insert(.securityCode) }
        .mpOnChange(of: self.cardForm.documentHolder) { _ in self.editedFields.insert(.document) }
        .onDisappear {
            if !self.didTapBack, !self.didComplete {
                self.onDismiss(self.cardForm.cancelledFormContext)
            }
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

    private func updateCardNumberLength(cardData: CardPaymentBrickCardData?) {
        if let method = cardData?.paymentMethods.first {
            self.cardForm.setCardNumberLength(method.cardNumber.length.min, method.cardNumber.length.max)
            self.cardForm.setSecurityCodeLength(method.securityCode.length)
        } else {
            self.cardForm.setCardNumberLength()
            self.cardForm.cleanSecurityCodeField()
        }
    }

    private func updateIdentificationTypes(_ identificationType: IdentificationType?) {
        guard let identificationType else { return }
        self.cardForm.setDocumentLength(identificationType.minLength, identificationType.maxLength)
        self.cardForm.setDocumentType(isNumeric: identificationType.type != "string")
    }
}
