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
                    VStack {
                        Button {
                        } label: {
                            Text(MPStrings.CardForm.button)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, theme.spacings.xmicro)
                                
                        }
                        .mpButtonStyle(variant: .loud)
                        .padding(.horizontal, theme.spacings.micro)
                        .hidden()
                        
                        MPFooter(
                            label: MPStrings.CardForm.total,
                            amount: MPStrings.formatPrice(100.0)
                        )
                    }
                }
            ) {
                VStack(spacing: theme.spacings.xsmall) {
                    MPTextField(
                        text: $cardNumber,
                        label: MPStrings.CardForm.CardNumber.label,
                        placeholder: MPStrings.CardForm.CardNumber.placeholder,
                        keyboard: .numberPad
                    )
                    
                    MPTextField(
                        text: $cardHolder,
                        label: MPStrings.CardForm.CardHolder.label,
                        placeholder: MPStrings.CardForm.CardHolder.placeholder
                    )
                    
                    HStack(spacing: theme.spacings.xsmall) {
                        MPTextField(
                            text: $expirationDate,
                            label: MPStrings.CardForm.Expiration.label,
                            placeholder: MPStrings.CardForm.Expiration.placeholder,
                            keyboard: .numberPad
                        )
                        
                        MPTextField(
                            text: $securityCode,
                            label: MPStrings.CardForm.CVV.label,
                            placeholder: MPStrings.CardForm.CVV.placeholderDefault,
                            keyboard: .numberPad,
                            suffix: {
                                Image(systemName: "questionmark.circle")
                                    .renderingMode(.template)
                                    .foregroundColor(theme.colors.interactive.fillLoudIdle)
                                    .padding(.horizontal, theme.spacings.micro)

                            }
                        )
                    }
                    
                    documentField()
                    
                }
                .padding(.horizontal, theme.spacings.micro)
            }
            .background(theme.colors.background.primary)
        }
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
                            .textStyle(.bodyMediumRegular(colorType: .secondary))
                        
                        Image(systemName: openDocumentsSheet ? "chevron.up" : "chevron.down")
                            .renderingMode(.template)
                            .foregroundColor(theme.colors.border.primary)
                            .padding(.horizontal, theme.spacings.xmicro)
                    }
                    .frame(maxHeight: .infinity)
                    .overlay(
                        Rectangle()
                            .frame(width: theme.borderWidth.small)
                            .foregroundColor(theme.colors.border.primary),
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
