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
    
    struct CardFormData {
        @CardFormValidate(
            .required(MPStrings.CardForm.CardNumber.errorEmpty),
            .cardNumber
        )
        var cardNumber: String = ""
        
        @CardFormValidate(
            .required(MPStrings.CardForm.CardHolder.errorEmpty),
            .cardHolder
        )
        var cardHolder: String = ""
        
        @CardFormValidate(
            .required(MPStrings.CardForm.Expiration.errorEmpty),
            .expirationDate
        )
        var expirationDate: String = ""
        
        @CardFormValidate(
            .required(MPStrings.CardForm.CVV.errorEmpty),
            .securityCode
        )
        public var securityCode: String = ""
        
        @CardFormValidate(
            .required(MPStrings.CardForm.Document.errorEmpty),
            .document
        )
        var documentHolder: String = ""
        
        
        mutating func setSecurityCodeLength(_ length: Int) {
            _securityCode.setSecurityCodeLength(length)
        }

        mutating func setDocumentLength(_ length: Int) {
            _documentHolder.setDocumentLength(length)
        }
    }
    
    @State private var cardForm = CardFormData()
    
    @Environment(\.checkoutTheme) var theme: MPTheme
    
    @Environment(\.presentationMode) var presentationMode

    // Formatters and Validators
    private let cardNumberFormatter = CardNumberFormatter()
    private let expirationDateFormatter = ExpirationDateFormatter()
    private let securityCodeFormatter = SecurityCodeFormatter()

    //  Document Field
    @State private var selectTypeDocument: IdentificationType = .init(name: "CPF")
    @State private var openDocumentsSheet: Bool = false

    var body: some View {
        NavigationView {
            MPHeader(
                title: MPStrings.CardForm.title,
                onBack: {
                    presentationMode.wrappedValue.dismiss()
                },
                footer: {
                    MPFooter(
                        label: MPStrings.CardForm.total,
                        amount: MPStrings.formatPrice(100.0),
                        buttonLabel: MPStrings.CardForm.button,
                        action: {
                            print("action button")
                        }
                    )
                }
            ) {
                VStack(spacing: theme.spacings.xsmall) {
                    cardNumberField()
                    
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
                        formatter: expirationDateFormatter,
                    )
                    
                    MPTextField(
                        text: $cardForm.securityCode,
                        label: MPStrings.CardForm.CVV.label,
                        placeholder: MPStrings.CardForm.CVV.placeholderDefault,
                        errorMessage: cardForm.$securityCode,
                        keyboard: .numberPad,
                        formatter: securityCodeFormatter,
                        popoverText: MPStrings.CardForm.CVV.tooltipStaticDefault
                    )
                    
                    
                    documentField()
                    
                }
                .padding(.horizontal, theme.spacings.micro)
            }
            .background(theme.colors.background.primary)
        }
    }
    
    @ViewBuilder
    func cardNumberField() -> some View {
        MPTextField(
            text: $cardForm.cardNumber,
            label: MPStrings.CardForm.CardNumber.label,
            placeholder: MPStrings.CardForm.CardNumber.placeholder,
            errorMessage: cardForm.$cardNumber,
            keyboard: .numberPad,
            formatter: cardNumberFormatter,
        )
    }
    
    @ViewBuilder
    func documentField() -> some View {
        MPTextField(
            text: $cardForm.documentHolder,
            label: MPStrings.CardForm.Document.label,
            placeholder: selectTypeDocument.placeholder,
            errorMessage: cardForm.$documentHolder,
            prefix: {
                dropdownDocument()
            },
        )
    }
    
    @ViewBuilder
    func dropdownDocument() -> some View {
        Button {
            openDocumentsSheet.toggle()
        } label: {
            HStack {
                Text(selectTypeDocument.name)
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
        .accessibility(label: Text(verbatim: selectTypeDocument.name))
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
