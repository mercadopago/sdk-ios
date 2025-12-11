//
//  CardFormBrick.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 14/11/25.
//
import SwiftUI
import MPComponents

struct CardFormBrick: View {
    @Environment(\.checkoutTheme) var theme: MPTheme
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var cardNumber: String = ""
    @State private var cardHolder: String = ""
    @State private var expirationDate: String = ""
    @State private var securityCode: String = ""
    
    @State private var openDocumentsSheet: Bool = false

    var body: some View {
        NavigationView {
            MPHeader(
                title: "Insira seu cartão",
                onBack: {
                    presentationMode.wrappedValue.dismiss()
                },
                footer: {
                    VStack {
                        Button {
                        } label: {
                            Text("Pagar")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, theme.spacings.xs)
                                
                        }
                        .mpButtonStyle(variant: .loud)
                        .padding(.horizontal,theme.spacings.s)
                        .hidden()
                        
                        MPFooter(label: "Total", amount: "R$ 500")
                    }
                }
            ) {
                VStack(spacing: theme.spacings.xl ){
                    MPTextField(
                        text: $cardNumber,
                        label: "Número do cartão",
                        placeholder: "1234 1234 1234 1234",
                        keyboard: .numberPad
                    )
                    
                    MPTextField(
                        text: $cardHolder,
                        label: "Nome do titular",
                        placeholder: "Ex.: Maria Lopes"
                    )
                    
                    HStack(spacing: theme.spacings.xl) {
                        MPTextField(
                            text: $expirationDate,
                            label: "Vencimento",
                            placeholder: "MM/AA",
                            keyboard: .numberPad
                        )
                        
                        MPTextField(
                            text: $securityCode,
                            label: "Código de segurança",
                            placeholder: "Ex.: 123",
                            keyboard: .numberPad,
                            suffix: {
                                Image(systemName: "questionmark.circle")
                                    .renderingMode(.template)
                                    .foregroundColor(theme.colors.accent)
                                    .padding(.horizontal,theme.spacings.s)

                            }
                        )
                    }
                    
                    documentField()
                    
                }
                .padding(.horizontal, theme.spacings.s)
            }
            .background(theme.colors.backgroundPrimary)
        }
    }
    
    
    
    @ViewBuilder
    func documentField() -> some View {
        MPTextField(
            text: $cardHolder,
            label: "Documento do titular",
            placeholder: "999.999.999-99",
            prefix: {
                Button {
                    openDocumentsSheet.toggle()
                } label: {
                    HStack {
                        Text("CPF")
                            .textStyle(.bodyMediumRegular(colorType: .secondary))
                        
                        Image(systemName: openDocumentsSheet ? "chevron.up" : "chevron.down")
                            .renderingMode(.template)
                            .foregroundColor(theme.colors.outlinePrimary)
                            .padding(.horizontal,theme.spacings.xs)
                    }
                    .frame(maxHeight: .infinity)
                    .overlay(
                        Rectangle()
                            .frame(width: theme.outline.xxs)
                            .foregroundColor(theme.colors.outlinePrimary),
                        alignment: .trailing
                    )
                    .padding(.leading,theme.spacings.s)
                }
            }
        )
    }
    
}

struct TelaCartao_Previews: PreviewProvider {
    static var previews: some View {
        ThemeProvider(
            light: MPLightTheme(),
            dark: MPLightTheme()
        ) {
            CardFormBrick()
        }

    }
}
