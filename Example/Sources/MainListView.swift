//
//  MainListView.swift
//  Example
//
//  Created by Guilherme Prata Costa on 16/01/25.
//

import MercadoPagoCheckout
import SwiftUI
import UIKit

struct MainListView: View {
    @State private var showingCardForm = false
    @State private var showingCardFormSwiftUI = false
    @State private var showDebug = false
    @State private var showBuilderShow = false
    @State private var showBuilderPresent = false
    @State private var cardTransactionExample: CardTransactionExample?
    @State private var alertItem: AlertItem?

    struct AlertItem: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    private enum CardTransactionExample: Int, Identifiable {
        case allTypes
        case creditOnly
        case visaMaster
        case maxInstallments
        var id: Int { rawValue }
    }

    var body: some View {
        NavigationView {
            List {
                Section("CoreMethods") {
                    Button("Card Form (UIKit)") {
                        self.showingCardForm = true
                    }
                    Button("Card Form (SwiftUI)") {
                        self.showingCardFormSwiftUI = true
                    }
                }

                Section("Save Card") {
                    Button("show(onResult:) - SwiftUI") {
                        self.showBuilderShow = true
                    }
                    .accessibilityIdentifier("show(onResult:) - SwiftUI")

                    Button("present(from:onResult:)") {
                        self.presentCheckout()
                    }
                    .accessibilityIdentifier("present(from:onResult:)")

                    Button("push(to:onResult:)") {
                        self.showBuilderPresent = true
                    }
                    .accessibilityIdentifier("push(to:onResult:)")
                }

                Section("Card Transaction") {
                    Button("Default (all types and brands)") {
                        self.cardTransactionExample = .allTypes
                    }
                    Button("Credit only") {
                        self.cardTransactionExample = .creditOnly
                    }
                    Button("Visa + Mastercard only") {
                        self.cardTransactionExample = .visaMaster
                    }
                    Button("Max 6 installments") {
                        self.cardTransactionExample = .maxInstallments
                    }
                }

                Section("Settings") {
                    Button("Debugging") {
                        self.showDebug = true
                    }
                    NavigationLink("About", destination: Text("Under construction"))
                }
            }
            .navigationTitle("Demo App")
        }
        .fullScreenCover(isPresented: self.$showingCardForm) {
            CardFormViewControllerRepresentable()
        }
        .fullScreenCover(isPresented: self.$showBuilderShow) {
            self.buildCheckout().show(onResult: self.handleResult)
        }
        .fullScreenCover(isPresented: self.$showBuilderPresent) {
            BuilderPushExample(checkout: self.buildCheckout(), onResult: { result in
                self.handleResult(result)
                self.showBuilderPresent = false
            })
        }
        .fullScreenCover(item: self.$cardTransactionExample) { example in
            self.buildCardTransactionCheckout(example).show(onResult: self.handleCardTransactionResult)
        }
        .sheet(isPresented: self.$showingCardFormSwiftUI) {
            CardFormView()
        }
        .sheet(isPresented: self.$showDebug) {
            DebugView()
        }
        .alert(item: self.$alertItem) { item in
            Alert(title: Text(item.title), message: Text(item.message))
        }
    }

    // MARK: - Save Card

    private func buildCheckout() -> MercadoPagoCheckout<MPPaymentData.CardSave> {
        MercadoPagoCheckout.Builder(
            checkoutType: .saveCard,
            checkoutAppearance: .init()
        )
        .setPaymentMethodConfiguration([
            .card(excludedTypes: [.prepaid])
        ])
        .build()
    }

    private func handleResult(_ result: MercadoPagoCheckoutResult<MPPaymentData.CardSave>) {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.6))
            switch result {
            case let .success(paymentData):
                print("Success: \(paymentData)")
                self.alertItem = AlertItem(
                    title: "Sucess",
                    message: "Method: \(paymentData.paymentMethodId)\nToken: \(paymentData.token)"
                )
            case let .error(error):
                print("Error: \(error)")
                self.alertItem = AlertItem(
                    title: "Error",
                    message: error.localizedDescription
                )
            case let .userCancelled(context):
                print("UserCancelled: \(context)")
                self.alertItem = AlertItem(
                    title: "Cancelled",
                    message: "User has cancelled."
                )
            }
        }
    }

    private func presentCheckout() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        self.buildCheckout().present(from: topVC, onResult: self.handleResult)
    }

    // MARK: - Card Transaction

    private func buildCardTransactionCheckout(_ example: CardTransactionExample) -> MercadoPagoCheckout<MPPaymentData.CardTransaction> {
        let order = MPOrder(amount: 100.0, payer: .init(email: "test@mp.com"), orderId: "12345")
        let builder = MercadoPagoCheckout.Builder(
            checkoutType: .cardTransaction(order: order),
            checkoutAppearance: .init()
        )
        switch example {
        case .allTypes:
            return builder.build()
        case .creditOnly:
            return builder
                .setPaymentMethodConfiguration([.card(excludedTypes: [.credit])])
                .build()
        case .visaMaster:
            return builder
                .setPaymentMethodConfiguration([.card(excludedBrands: [.visa, .master])])
                .build()
        case .maxInstallments:
            return builder
                .setPaymentMethodConfiguration([.card(installment: .init(maxInstallments: 6))])
                .build()
        }
    }

    private func handleCardTransactionResult(_ result: MercadoPagoCheckoutResult<MPPaymentData.CardTransaction>) {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.6))
            switch result {
            case let .success(paymentData):
                print("Success: \(paymentData)")
                self.alertItem = AlertItem(
                    title: "Success",
                    message: "Method: \(paymentData.paymentMethodId)\nInstallments: \(paymentData.installment ?? 1)"
                )
            case let .error(error):
                print("Error: \(error)")
                self.alertItem = AlertItem(
                    title: "Error",
                    message: error.localizedDescription
                )
            case let .userCancelled(context):
                print("UserCancelled: \(context)")
                self.alertItem = AlertItem(
                    title: "Cancelled",
                    message: "User has cancelled."
                )
            }
        }
    }
}

// MARK: - Builder push(to:) example

struct BuilderPushExample: UIViewControllerRepresentable {
    let checkout: MercadoPagoCheckout<MPPaymentData.CardSave>
    let onResult: (MercadoPagoCheckoutResult<MPPaymentData.CardSave>) -> Void

    func makeUIViewController(context _: Context) -> UINavigationController {
        let nav = UINavigationController()
        nav.setNavigationBarHidden(true, animated: false)
        DispatchQueue.main.async {
            self.checkout.push(to: nav, onResult: self.onResult)
        }
        return nav
    }

    func updateUIViewController(_: UINavigationController, context _: Context) {}
}

struct CardFormViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let cardFormVC = CardFormViewController()
        let navigationController = UINavigationController(rootViewController: cardFormVC)

        cardFormVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: context.coordinator,
            action: #selector(Coordinator.dismiss)
        )
        cardFormVC.title = "Card Form"
        return navigationController
    }

    func updateUIViewController(_: UINavigationController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: CardFormViewControllerRepresentable

        init(_ parent: CardFormViewControllerRepresentable) {
            self.parent = parent
        }

        @objc func dismiss() {
            UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
        }
    }
}

/// Preview
struct MainListView_Previews: PreviewProvider {
    static var previews: some View {
        MainListView()
    }
}
