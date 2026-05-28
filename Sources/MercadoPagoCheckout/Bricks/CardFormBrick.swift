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
    @State private var cardTransactionData: MPPaymentData.CardTransaction
    @ObservedObject private var brickViewModel: CardFormBrickViewModel<T>

    private var configuration: MPCheckoutConfiguration<T>
    private let themeDark: MPTheme
    private let themeLight: MPTheme
    private let transactionAmount: Double

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
        self.transactionAmount = configuration.type.configuration.amount
        self.configuration = configuration
        self._cardTransactionData = State(
            initialValue: .init()
        )
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

    private func cardFormScreen(initResult: CardFormInitializationOutput, viewModel: CardFormViewModel<T>) -> some View {
        CardFormScreen(
            initResult: initResult,
            transactionAmount: self.transactionAmount,
            viewModel: viewModel,
            onBack: { context in
                viewModel.cancel(context: context, reason: .backButton)
                self.cancelCheckout(context: .cardForm(context))
            },
            onDismiss: { context in
                viewModel.cancel(context: context, reason: .dismissedScreen)
                self.route = nil
                self.onResult(.userCancelled(.cardForm(context)))
            },
            onSuccess: { paymentData in
                if let transaction = paymentData as? MPPaymentData.CardTransaction {
                    self.cardTransactionData = transaction
                }
                self.completeCheckout(with: paymentData)
            },
            onFailure: { error in
                self.fail(error)
            }
        )
    }

    private func installmentScreen() -> some View {
        InstallmentScreen(
            paymentData: self.$cardTransactionData,
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

    private func cancelCheckout(context: MPUserCancelledContext) {
        self.route = nil
        self.onResult(.userCancelled(context))
        self.presentationMode.wrappedValue.dismiss()
    }

    /// Emits the final success result.
    ///
    /// The SDK guarantees by construction that the variant of `paymentData` matches `T`
    /// (a `cardTransaction` ``CheckoutType`` always yields a ``MPPaymentData/CardTransaction``;
    /// `saveCard` always yields a ``MPPaymentData/CardSave``). The forced cast is the iOS
    /// equivalent of Android's `@Suppress("UNCHECKED_CAST")`.
    private func completeCheckout(with paymentData: any MPPaymentData.Kind) {
        guard let typed = paymentData as? T else {
            assertionFailure("CardFormBrick received \(type(of: paymentData)) but was configured for \(T.self).")
            return
        }
        self.route = nil
        self.onResult(.success(typed))
        self.presentationMode.wrappedValue.dismiss()
    }

    private func fail(_ error: MercadoPagoCheckoutError) {
        self.route = nil
        self.onResult(.error(error))
        self.presentationMode.wrappedValue.dismiss()
    }
}
