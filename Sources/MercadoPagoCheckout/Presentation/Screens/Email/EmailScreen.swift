//
//  EmailScreen.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 02/06/26.
//

import MPComponents
import SwiftUI

struct EmailScreen: View {
    @Environment(\.checkoutTheme) var theme: MPTheme

    @ObservedObject private var viewModel: EmailViewModel

    @State private var isEmailFocused = false

    private let onBack: () -> Void
    private let onContinue: (String) -> Void

    init(
        viewModel: EmailViewModel,
        onBack: @escaping () -> Void = {},
        onContinue: @escaping (String) -> Void = { _ in }
    ) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onBack = onBack
        self.onContinue = onContinue
    }

    var body: some View {
        MPHeader(
            title: self.viewModel.initResult.title,
            onBack: self.onBack,
            content: {
                MPTextField(
                    text: self.$viewModel.email,
                    label: self.viewModel.initResult.label,
                    placeholder: self.viewModel.initResult.placeholder,
                    errorMessage: self.viewModel.emailErrors(),
                    keyboard: .emailAddress,
                    contentType: .emailAddress,
                    autocorrection: .no
                )
                .mpFocused(self.$isEmailFocused)
                .padding(.horizontal, self.theme.spacings.micro)
            },
            footer: {
                MPFooter(
                    buttonData: .init(
                        text: self.viewModel.initResult.button,
                        onClick: {
                            self.onContinue(self.viewModel.email)
                        }
                    )
                )
                .disabled(!self.viewModel.isEmailValid)
            }
        )
        .background(self.theme.colors.background.primary.edgesIgnoringSafeArea(.all))
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onAppear {
            self.isEmailFocused = true
        }
    }
}

#if DEBUG
    #Preview {
        EmailScreen(
            viewModel: EmailViewModel(
                config: .init(
                    initResult: EmailInitializationOutput(
                        title: "Completá el e-mail",
                        button: "Continuar",
                        label: "E-mail",
                        email: "maria@mail.com",
                        placeholder: "Ejemplo: juan.perez@gmail.com",
                        errorEmpty: "Completá este campo.",
                        errorInvalid: "Ingresá un e-mail válido."
                    )
                )
            )
        )
    }
#endif
