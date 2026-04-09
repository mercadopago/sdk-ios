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
    @State private var showBuilderSheet = false
    @State private var alertItem: AlertItem?

    struct AlertItem: Identifiable {
        let id = UUID()
        let title: String
        let message: String
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

                Section("Card Payment") {
                    Button("show(onResult:) - SwiftUI") {
                        self.showBuilderShow = true
                    }
                    .accessibilityIdentifier("show(onResult:) - SwiftUI")

                    Button("sheet(onResult:) - Modal") {
                        self.showBuilderSheet = true
                    }
                    .accessibilityIdentifier("sheet(onResult:) - Modal")

                    Button("present(from:onResult:)") {
                        self.presentCheckout()
                    }
                    .accessibilityIdentifier("present(from:onResult:)")

                    Button("push(to:onResult:)") {
                        self.showBuilderPresent = true
                    }
                    .accessibilityIdentifier("push(to:onResult:)")
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
        .sheet(isPresented: self.$showBuilderSheet) {
            self.buildCheckout().show(onResult: self.handleResult)
        }
        .fullScreenCover(isPresented: self.$showBuilderPresent) {
            BuilderPushExample(checkout: self.buildCheckout(), onResult: { result in
                self.handleResult(result)
                self.showBuilderPresent = false
            })
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

    private func buildCheckout() -> MercadoPagoCheckout {
        let builder = MercadoPagoCheckout.Builder(
            checkoutType: .cardForm(cardFormConfiguration: .init()),
            checkoutAppearance: .init()
        )

        builder.setPaymentMethods([
            .card(allowedTypes: [.credit, .debit])
        ])
        return builder.build()
    }

    private func handleResult(_ result: MercadoPagoCheckoutResult) {
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
}

// MARK: - Builder push(to:) example

struct BuilderPushExample: UIViewControllerRepresentable {
    let checkout: MercadoPagoCheckout
    let onResult: (MercadoPagoCheckoutResult) -> Void

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
