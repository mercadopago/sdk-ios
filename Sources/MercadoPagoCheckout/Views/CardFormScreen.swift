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
    @ObservedObject private var viewModel: CardFormViewModel
    
    // MARK: States View
    @State private var cardForm = CardFormData()
    @State private var openDocumentsSheet: Bool = false

    // MARK: Enviroments
    @Environment(\.checkoutTheme) var theme: MPTheme
    @Environment(\.presentationMode) var presentationMode

    init(viewModel: CardFormViewModel = CardFormViewModel()) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            MPHeader(
                title: MPStrings.CardForm.title,
                onBack: {
                    presentationMode.wrappedValue.dismiss()
                },
                footer: {
                    MPFooter(
                        label: MPStrings.Common.total,
                        amount: MPStrings.formatPrice(100.0),
                        buttonLabel: MPStrings.CardForm.button,
                        action: {
                            print("action button")
                        }
                    )
                    .disabled(!cardForm.isFormValid)
                }
            ) {
                VStack(spacing: theme.spacings.xsmall) {
                    
                    Text("\(cardForm.isFormValid)")
                    
                    MPTextField(
                        text: $cardForm.cardNumber,
                        label: MPStrings.CardForm.CardNumber.label,
                        placeholder: MPStrings.CardForm.CardNumber.placeholder,
                        errorMessage: cardForm.$cardNumber,
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
                        placeholder: viewModel.selectTypeDocument.placeholder,
                        errorMessage: cardForm.$documentHolder,
                        prefix: {
                            dropdownDocument()
                        },
                    )
                    
                }
                .padding(.horizontal, theme.spacings.micro)
            }
            .background(theme.colors.background.primary)
        }
    }
        
    @ViewBuilder
    func dropdownDocument() -> some View {
        Button {
            openDocumentsSheet.toggle()
        } label: {
            HStack {
                Text(viewModel.selectTypeDocument.name)
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
        .accessibility(label: Text(verbatim: viewModel.selectTypeDocument.name))
    }
}

struct CardForm_Previews: PreviewProvider {
    static var previews: some View {
        ThemeProvider(
            light: MPLightTheme(),
            dark: MPLightTheme()
        ) {
            CardFormScreen()
        }

    }
}
