//
//  CardFormBrick.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/12/25.
//
import MPComponents
import SwiftUI

struct CardFormBrick<T: MPPaymentData.Kind>: View {
    private enum Route: Hashable {
        case installments
        case reviewAndConfirm
    }

    @State private var route: Route?
    @State private var pendingResult: T?
    @ObservedObject private var brickViewModel: CardFormBrickViewModel<T>

    private let configuration: MPCheckoutConfiguration<T>
    private let themeDark: MPTheme
    private let themeLight: MPTheme

    private let onResult: (MercadoPagoCheckoutResult<T>) -> Void

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.checkoutTheme) private var theme: MPTheme

    @MainActor
    init(
        configuration: MPCheckoutConfiguration<T>,
        appearance: MPCheckoutAppearance,
        onResult: @escaping (MercadoPagoCheckoutResult<T>) -> Void
    ) {
        self.onResult = onResult
        self.themeDark = appearance.themeConfiguration.dark
        self.themeLight = appearance.themeConfiguration.light
        self.configuration = configuration
        self.brickViewModel = CardFormBrickViewModel<T>(configuration: configuration, appearance: appearance)
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
                        self.cardFormScreen(viewModel: cardFormViewModel)
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

    private func cardFormScreen(viewModel: CardFormViewModel) -> some View {
        CardFormScreen(
            viewModel: viewModel,
            onBack: { context in
                viewModel.cancel(context: context, reason: .backButton)
                self.cancelCheckout(cardForm: context)
            },
            onDismiss: { context in
                viewModel.cancel(context: context, reason: .dismissedScreen)
                self.route = nil
                self.emitUserCancelled(cardForm: context)
            },
            onSuccess: { output in
                self.pendingResult = self.brickViewModel.buildPaymentData(from: output)
                self.completeCheckout()
            },
            onFailure: { error in
                self.fail(error)
            }
        )
    }

    private func installmentScreen() -> some View {
        InstallmentScreen(
            paymentData: Binding(
                get: { (self.pendingResult as? MPPaymentData.CardTransaction) ?? .init() },
                set: { self.pendingResult = $0 as? T }
            ),
            installments: InstallmentMock.visa,
            onBack: {
                self.presentationMode.wrappedValue.dismiss()
            },
            onContinue: {
                self.route = .reviewAndConfirm
            }
        )
        .listItemStyle(.radioButton)
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

    private func cancelCheckout(cardForm context: MPCardFormUserCancelledContext) {
        self.route = nil
        self.emitUserCancelled(cardForm: context)
        self.presentationMode.wrappedValue.dismiss()
    }

    /// Builds the concrete cancellation context for the configured checkout type and delivers it
    /// through ``MercadoPagoCheckoutResult/userCancelled(_:)``.
    ///
    /// `T.Cancellation` is fixed by the configured ``MercadoPagoCheckout/CheckoutType``:
    /// `.cardTransaction(order:)` produces a ``MPUserCancelledContext/CardTransaction`` and
    /// `.saveCard` produces a ``MPUserCancelledContext/CardSave``.
    private func emitUserCancelled(cardForm context: MPCardFormUserCancelledContext, screens: [Screen] = []) {
        let cancellation: (any MPUserCancelledContext.Kind)?
        if T.Cancellation.self == MPUserCancelledContext.CardSave.self {
            cancellation = MPUserCancelledContext.CardSave(cardForm: context)
        } else if T.Cancellation.self == MPUserCancelledContext.CardTransaction.self {
            cancellation = MPUserCancelledContext.CardTransaction(cardForm: context, screens: screens)
        } else if T.Cancellation.self == MPUserCancelledContext.Payment.self {
            cancellation = MPUserCancelledContext.Payment(screens: screens)
        } else {
            cancellation = nil
        }
        guard let typed = cancellation as? T.Cancellation else {
            assertionFailure("CardFormBrick could not build \(T.Cancellation.self) cancellation context.")
            return
        }
        self.onResult(.userCancelled(typed))
    }

    /// Delivers the successful payment data through ``MercadoPagoCheckoutResult/success(_:)``.
    ///
    /// Uses the typed ``pendingResult`` built from the card form output, which always matches the
    /// configured ``MercadoPagoCheckout/CheckoutType``: `.cardTransaction(order:)` yields a
    /// ``MPPaymentData/CardTransaction`` and `.saveCard` yields a ``MPPaymentData/CardSave``.
    private func completeCheckout() {
        guard let result = self.pendingResult else {
            assertionFailure("CardFormBrick has no payment data to complete the checkout.")
            return
        }
        self.route = nil
        self.onResult(.success(result))
        self.presentationMode.wrappedValue.dismiss()
    }

    private func fail(_ error: MercadoPagoCheckoutError) {
        self.route = nil
        self.onResult(.error(error))
        self.presentationMode.wrappedValue.dismiss()
    }
}
