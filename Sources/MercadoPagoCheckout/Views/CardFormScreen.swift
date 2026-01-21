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
    @Environment(\.checkoutTheme) var theme: MPTheme
    
    @Environment(\.presentationMode) var presentationMode
    
    // Card Form Fields
    @State private var cardNumber: String = ""
    @State private var cardHolder: String = ""
    @State private var expirationDate: String = ""
    @State private var securityCode: String = ""
    
    // Formatters and Validators
    private let cardNumberFormatter = CardNumberFormatter()
    private let cardNumberValidator = CardNumberValidator()
    private let expirationDateFormatter = ExpirationDateFormatter()
    private let expirationDateValidator = ExpirationDateValidator()
    private let securityCodeFormatter = SecurityCodeFormatter()
    private let securityCodeValidator = SecurityCodeValidator()
    
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
                        text: $cardHolder,
                        label: MPStrings.CardForm.CardHolder.label,
                        placeholder: MPStrings.CardForm.CardHolder.placeholder
                    )
                    
                                    }

                    MPTextField(
                        text: $expirationDate,
                        label: MPStrings.CardForm.Expiration.label,
                        placeholder: MPStrings.CardForm.Expiration.placeholder,
                        keyboard: .numberPad,
                        formatter: expirationDateFormatter,
                        validator: expirationDateValidator
                    )
                    
                    MPTextField(
                        text: $securityCode,
                        label: MPStrings.CardForm.CVV.label,
                        placeholder: MPStrings.CardForm.CVV.placeholderDefault,
                        keyboard: .numberPad,
                        formatter: securityCodeFormatter,
                        validator: securityCodeValidator
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
            text: $cardNumber,
            label: MPStrings.CardForm.CardNumber.label,
            placeholder: MPStrings.CardForm.CardNumber.placeholder,
            keyboard: .numberPad,
            formatter: cardNumberFormatter,
            validator: cardNumberValidator
        )
    }
    
    @ViewBuilder
    func documentField() -> some View {
        MPTextField(
            text: $cardHolder,
            label: MPStrings.CardForm.CardHolder.label,
            placeholder: selectTypeDocument.placeholder,
            prefix: {
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
            }
        )
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
