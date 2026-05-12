//
//  CardFormBrick.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/12/25.
//
import MPComponents
import SwiftUI

struct CardFormBrick: View {
    private enum Route: Hashable {
        case installments
        case reviewAndConfirm
    }

    @State private var route: Route?
    @State private var paymentData: MPPaymentData
    @State private var installmentsData: MPInstallmentsData
    @ObservedObject private var brickViewModel: CardFormBrickViewModel

    private var configuration: MercadoPagoCheckout.CheckoutConfiguration
    private let themeDark: MPTheme
    private let themeLight: MPTheme
    private let transactionAmount: Double?

    private let onResult: (MercadoPagoCheckoutResult) -> Void

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.checkoutTheme) private var theme: MPTheme

    init(
        configuration: MercadoPagoCheckout.CheckoutConfiguration,
        appearance: MercadoPagoCheckout.CheckoutAppearance,
        onResult: @escaping (MercadoPagoCheckoutResult) -> Void
    ) {
        self.onResult = onResult
        self.themeDark = appearance.themeConfiguration.dark
        self.themeLight = appearance.themeConfiguration.light
        self.transactionAmount = configuration.type.configuration.amount
        self.configuration = configuration
        self._paymentData = State(initialValue: MPPaymentData(transactionAmount: self.transactionAmount))
        self._installmentsData = State(initialValue: .empty)
        self.brickViewModel = CardFormBrickViewModel(configuration: configuration, appearance: appearance)
    }

    var body: some View {
        ThemeProvider(
            light: self.themeLight,
            dark: self.themeDark
        ) {
            NavigationView {
                ZStack {
                    switch self.brickViewModel.screenState {
                    case .loading:
                        ZStack {
                            self.theme.colors.background.primary
                                .edgesIgnoringSafeArea(.all)
                            MPProgressIndicator()
                                .size(.xlarge)
                        }
                    case let .ready(initResult, cardFormViewModel):
                        self.cardFormScreen(initResult: initResult, viewModel: cardFormViewModel)
                    }
                    self.navigationLinks()
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .mpTask {
            do {
                try await self.brickViewModel.load()
            } catch let error as MercadoPagoCheckoutError {
                self.fail(error)
            } catch {
                let checkoutError = MercadoPagoCheckoutError(
                    code: .unknown,
                    localizedDescription: error.localizedDescription,
                    location: .initialization
                )
                self.fail(checkoutError)
            }
        }
    }

    private func cardFormScreen(initResult: CardFormInitializationOutput, viewModel: CardFormViewModel) -> some View {
        CardFormScreen(
            initResult: initResult,
            transactionAmount: self.transactionAmount,
            viewModel: viewModel,
            onBack: { context in
                viewModel.cancel(context: context, reason: .backButton)
                let updatedContext = CardFormUserCancelledContext(
                    fields: context.fields,
                    installmentsWasPresented: self.brickViewModel.installmentsWasPresented
                )
                self.cancelCheckout(context: .cardForm(updatedContext))
            },
            onDismiss: { context in
                viewModel.cancel(context: context, reason: .dismissedScreen)
                let updatedContext = CardFormUserCancelledContext(
                    fields: context.fields,
                    installmentsWasPresented: self.brickViewModel.installmentsWasPresented
                )
                self.route = nil
                self.onResult(.userCancelled(.cardForm(updatedContext)))
            },
            onSuccess: { paymentData, installmentsData in
                self.paymentData = paymentData
                if let installmentsData {
                    self.installmentsData = installmentsData
                    self.brickViewModel.markInstallmentsPresented()
                    self.route = .installments
                } else {
                    self.completeCheckout()
                }
            },
            onFailure: { error in
                self.fail(error)
            }
        )
    }

    private func installmentScreen() -> some View {
        InstallmentScreen(
            paymentData: self.$paymentData,
            installmentsData: self.$installmentsData,
            onBack: {
                self.route = nil
            },
            onDismiss: {
                self.cancelCheckout(context: .installments)
            },
            onFinish: { paymentData in
                self.paymentData = paymentData
                self.completeCheckout()
            },
            onContinue: { paymentData in
                self.paymentData = paymentData
                self.route = .reviewAndConfirm
            }
        )
    }

    private func navigationLinks() -> some View {
        Group {
            NavigationLink(
                destination: self.installmentScreen(),
                tag: .installments,
                selection: self.$route
            ) {
                EmptyView()
            }
            .hidden()
        }
    }

    private func cancelCheckout(context: UserCancelledContext) {
        self.route = nil
        self.onResult(.userCancelled(context))
        self.presentationMode.wrappedValue.dismiss()
    }

    private func completeCheckout() {
        self.route = nil
        self.onResult(.success(self.paymentData))
        self.presentationMode.wrappedValue.dismiss()
    }

    private func fail(_ error: MercadoPagoCheckoutError) {
        self.route = nil
        self.onResult(.error(error))
        self.presentationMode.wrappedValue.dismiss()
    }
}
