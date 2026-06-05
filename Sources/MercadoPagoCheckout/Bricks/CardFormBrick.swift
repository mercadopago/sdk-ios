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
    @State private var installmentsData: MPInstallmentsData
    @State private var processingTask: Task<Void, Never>?
    @State private var isProcessingOrder = false
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
        self._installmentsData = State(initialValue: .empty)
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
        .onDisappear {
            self.processingTask?.cancel()
        }
    }

    private func cardFormScreen(viewModel: CardFormViewModel) -> some View {
        CardFormScreen(
            viewModel: viewModel,
            onBack: { context in
                viewModel.cancel(context: context, reason: .backButton)
                let updatedContext = MPCardFormUserCancelledContext(
                    fields: context.fields,
                    installmentsWasPresented: self.brickViewModel.installmentsWasPresented
                )
                self.cancelCheckout(context: .cardForm(updatedContext))
            },
            onDismiss: { context in
                viewModel.cancel(context: context, reason: .dismissedScreen)
                let updatedContext = MPCardFormUserCancelledContext(
                    fields: context.fields,
                    installmentsWasPresented: self.brickViewModel.installmentsWasPresented
                )
                self.route = nil
                self.onResult(.userCancelled(.cardForm(updatedContext)))
            },
            onSuccess: { output, installmentsData in
                self.pendingResult = self.brickViewModel.buildPaymentData(from: output)
                if let installmentsData {
                    self.handleInstallments(installmentsData)
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
            paymentData: Binding(
                get: { (self.pendingResult as? MPPaymentData.CardTransaction) ?? .init() },
                set: { self.pendingResult = $0 as? T }
            ),
            installmentsData: self.$installmentsData,
            checkoutType: self.configuration.type.analyticsValue,
            onBack: {
                self.route = nil
            },
            onDismiss: {
                self.cancelCheckout(context: .installments)
            },
            onFinish: { context in
                self.completeTransactionCheckout(installments: context.installments)
            },
            onContinue: { paymentData in
                if let paymentData = paymentData as? MPPaymentData.CardTransaction {
                    self.pendingResult = paymentData as? T
                    self.route = .reviewAndConfirm
                }
            }
        )
    }

    private func navigationLinks() -> some View {
        Group {
            NavigationLink(
                destination: self.installmentScreen().isLoading(self.isProcessingOrder),
                tag: .installments,
                selection: self.$route
            ) {
                EmptyView()
            }
            .hidden()
        }
    }

    // MARK: - Navigation

    private func handleInstallments(_ installmentsData: MPInstallmentsData) {
        if installmentsData.installment.quotas.count > 1 {
            self.installmentsData = installmentsData
            self.brickViewModel.markInstallmentsPresented()
            self.route = .installments
        } else {
            self.completeTransactionCheckout(installments: installmentsData.installment.quotas.first?.installments ?? 1)
        }
    }

    private func cancelCheckout(context: MPUserCancelledContext) {
        self.route = nil
        self.onResult(.userCancelled(context))
        self.presentationMode.wrappedValue.dismiss()
    }

    private func completeCheckout() {
        guard let result = self.pendingResult else {
            assertionFailure("completeCheckout called with no pendingResult")
            return
        }
        self.route = nil
        self.onResult(.success(result))
        self.presentationMode.wrappedValue.dismiss()
    }

    private func completeTransactionCheckout(installments: Int = 1) {
        guard var paymentData = self.pendingResult as? MPPaymentData.CardTransaction else {
            assertionFailure("completeTransactionCheckout: invalid payment data")
            return
        }
        paymentData.installment = installments
        self.processingTask = Task {
            self.isProcessingOrder = true
            defer { self.isProcessingOrder = false }
            do {
                let updatedPaymentData = try await self.brickViewModel.processOrderTask(paymentData)
                self.pendingResult = updatedPaymentData as? T
                guard let result = self.pendingResult else { return }
                self.route = nil
                self.onResult(.success(result))
                self.presentationMode.wrappedValue.dismiss()
            } catch is CancellationError {
                return
            } catch let error as MercadoPagoCheckoutError {
                self.fail(error)
            } catch {
                return
            }
        }
    }

    private func fail(_ error: MercadoPagoCheckoutError) {
        self.route = nil
        self.onResult(.error(error))
        self.presentationMode.wrappedValue.dismiss()
    }
}
