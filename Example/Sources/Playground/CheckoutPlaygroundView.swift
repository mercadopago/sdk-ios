//
//  CheckoutPlaygroundView.swift
//  Example
//
//  A single configurable panel to exercise every MercadoPagoCheckout option:
//  checkout type, installments, order data, public key/country, appearance and
//  presentation mode (SwiftUI `show`, UIKit `present`, UIKit `push`).
//

import CoreMethods
import MercadoPagoCheckout
import SwiftUI
import UIKit

@available(iOS 14.0, *)
struct CheckoutPlaygroundView: View {
    @StateObject private var config = CheckoutConfig()

    @State private var preparedCheckout: PreparedCheckout?
    @State private var sheetCheckout: PreparedCheckout?
    @State private var showExclusions = false
    @State private var alertItem: AlertItem?

    struct AlertItem: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    /// A checkout view built once at launch time, so it keeps a stable identity
    /// while presented (rebuilding `show()` on every body re-render would make
    /// `CardFormScreen` fire `userCancelled` from its `.onDisappear`).
    private struct PreparedCheckout: Identifiable {
        let id = UUID()
        let view: AnyView
    }

    private static let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    var body: some View {
        Form {
            self.sdkSection
            self.checkoutSection
            if self.config.checkoutType == .cardTransaction {
                self.orderSection
            }
            self.installmentsSection
            self.exclusionsSection
            self.appearanceSection
            self.launchSection
        }
        .navigationTitle("Checkout Playground")
        .sheet(isPresented: self.$showExclusions) {
            ExclusionsSheet(config: self.config)
        }
        .sheet(item: self.$sheetCheckout) { prepared in
            prepared.view
        }
        .fullScreenCover(item: self.$preparedCheckout) { prepared in
            prepared.view
        }
        .alert(item: self.$alertItem) { item in
            Alert(title: Text(item.title), message: Text(item.message))
        }
    }

    // MARK: - Sections

    private var sdkSection: some View {
        Section("SDK") {
            TextField("Public Key", text: self.$config.publicKey)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .accessibilityIdentifier("playground.publicKey")
            Picker("Country", selection: self.$config.country) {
                ForEach(MercadoPagoSDK.Country.pickerOptions, id: \.rawValue) { country in
                    Text(country.rawValue)
                        .tag(country)
                        .accessibilityIdentifier("playground.country.\(country.rawValue)")
                }
            }
            .accessibilityIdentifier("playground.country")
            Button("Reinitialize SDK") {
                let key = self.config.publicKey
                guard key.hasPrefix("APP_USR-") || key.hasPrefix("TEST-") else {
                    self.alertItem = AlertItem(
                        title: "Invalid public key",
                        message: "Use the APP_USR-... or TEST-... format."
                    )
                    return
                }
                self.config.applySDKConfiguration()
                self.alertItem = AlertItem(
                    title: "SDK updated",
                    message: "Public key and country applied."
                )
            }
            .accessibilityIdentifier("playground.reinitializeSDK")
        }
    }

    private var checkoutSection: some View {
        Section("Checkout") {
            Picker("Type", selection: self.$config.checkoutType) {
                ForEach(CheckoutTypeOption.allCases) { option in
                    Text(option.title)
                        .tag(option)
                        .accessibilityIdentifier("playground.checkoutType.\(option.rawValue)")
                }
            }
            .accessibilityIdentifier("playground.checkoutType")
            Picker("Presentation", selection: self.$config.presentation) {
                ForEach(PresentationMode.allCases) { mode in
                    Text(mode.title)
                        .tag(mode)
                        .accessibilityIdentifier("playground.presentation.\(mode.rawValue)")
                }
            }
            .accessibilityIdentifier("playground.presentation")
        }
    }

    private var orderSection: some View {
        Section("Order") {
            TextField("Amount", value: self.$config.amount, formatter: Self.amountFormatter)
                .keyboardType(.decimalPad)
                .accessibilityIdentifier("playground.amount")
            TextField("Payer Email", text: self.$config.email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .accessibilityIdentifier("playground.email")
            TextField("Order ID", text: self.$config.orderId)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .accessibilityIdentifier("playground.orderId")
        }
    }

    private var installmentsSection: some View {
        Section("Installments") {
            LabeledContent("Min") {
                TextField("Min", text: self.$config.minInstallmentsText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .accessibilityIdentifier("playground.minInstallments")
            }
            LabeledContent("Max") {
                TextField("Max", text: self.$config.maxInstallmentsText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .accessibilityIdentifier("playground.maxInstallments")
            }
        }
    }

    private var exclusionsSection: some View {
        Section("Payment methods") {
            Button {
                self.showExclusions = true
            } label: {
                HStack {
                    Text("Exclusions")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(self.exclusionsSummary)
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Color(.tertiaryLabel))
                }
            }
            .accessibilityIdentifier("playground.exclusions")
        }
    }

    private var exclusionsSummary: String {
        let typeCount = self.config.excludedTypes.count
        let brandCount = self.config.excludedBrands.count
        guard typeCount > 0 || brandCount > 0 else { return "None" }
        var parts: [String] = []
        if typeCount > 0 { parts.append("\(typeCount) type\(typeCount == 1 ? "" : "s")") }
        if brandCount > 0 { parts.append("\(brandCount) brand\(brandCount == 1 ? "" : "s")") }
        return parts.joined(separator: " · ")
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Style", selection: self.$config.appearance) {
                ForEach(AppearanceStyleOption.allCases) { style in
                    Text(style.title)
                        .tag(style)
                        .accessibilityIdentifier("playground.appearance.\(style.rawValue)")
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("playground.appearance")
        }
    }

    private var launchSection: some View {
        Section {
            Button {
                self.launch()
            } label: {
                Text("Open Checkout")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
            }
            .accessibilityIdentifier("playground.openCheckout")
        }
    }

    // MARK: - Launch

    @MainActor
    private func launch() {
        switch self.config.presentation {
        case .swiftUIShow:
            self.preparedCheckout = PreparedCheckout(view: self.makeSwiftUIShowView())
        case .swiftUISheet:
            self.sheetCheckout = PreparedCheckout(view: self.makeSwiftUIShowView())
        case .uikitPresent:
            self.presentUIKitCheckout()
        case .uikitPush:
            self.preparedCheckout = PreparedCheckout(view: self.makeUIKitPushView())
        }
    }

    @MainActor
    private func makeSwiftUIShowView() -> AnyView {
        switch self.config.checkoutType {
        case .saveCard:
            return AnyView(self.config.makeCardSaveCheckout().show(onResult: self.handleSaveResult))
        case .cardTransaction:
            return AnyView(self.config.makeCardTransactionCheckout().show(onResult: self.handleTransactionResult))
        }
    }

    @MainActor
    private func makeUIKitPushView() -> AnyView {
        switch self.config.checkoutType {
        case .saveCard:
            return AnyView(CheckoutPushRepresentable(
                checkout: self.config.makeCardSaveCheckout(),
                onResult: self.handleSaveResult
            ))
        case .cardTransaction:
            return AnyView(CheckoutPushRepresentable(
                checkout: self.config.makeCardTransactionCheckout(),
                onResult: self.handleTransactionResult
            ))
        }
    }

    private func presentUIKitCheckout() {
        guard let topVC = Self.topViewController() else { return }
        switch self.config.checkoutType {
        case .saveCard:
            self.config.makeCardSaveCheckout().present(from: topVC, onResult: self.handleSaveResult)
        case .cardTransaction:
            self.config.makeCardTransactionCheckout().present(from: topVC, onResult: self.handleTransactionResult)
        }
    }

    private static func topViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return nil }
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        return topVC
    }

    // MARK: - Result handling

    private func handleSaveResult(_ result: MercadoPagoCheckoutResult<MPPaymentData.CardSave>) {
        Task { @MainActor in
            self.preparedCheckout = nil
            self.sheetCheckout = nil
            try? await Task.sleep(for: .seconds(0.6))
            guard self.preparedCheckout == nil, self.sheetCheckout == nil else { return }
            switch result {
            case let .success(paymentData):
                self.alertItem = AlertItem(
                    title: "Success",
                    message: "Method: \(paymentData.paymentMethodId)\nToken: \(paymentData.token)"
                )
            case let .error(error):
                self.alertItem = AlertItem(title: "Error", message: error.localizedDescription)
            case let .userCancelled(context):
                print("Contexto: ", context)
                self.alertItem = AlertItem(title: "Cancelled", message: "User has cancelled.")
            }
        }
    }

    private func handleTransactionResult(_ result: MercadoPagoCheckoutResult<MPPaymentData.CardTransaction>) {
        Task { @MainActor in
            self.preparedCheckout = nil
            self.sheetCheckout = nil
            try? await Task.sleep(for: .seconds(0.6))
            guard self.preparedCheckout == nil, self.sheetCheckout == nil else { return }
            switch result {
            case let .success(paymentData):
                self.alertItem = AlertItem(
                    title: "Success",
                    message: "Method: \(paymentData.paymentMethodId)\nInstallments: \(paymentData.installment ?? 1)"
                )
            case let .error(error):
                self.alertItem = AlertItem(title: "Error", message: error.localizedDescription)
            case let .userCancelled(context):
                print("Contexto: ", context)
                self.alertItem = AlertItem(title: "Cancelled", message: "User has cancelled.")
            }
        }
    }
}

// MARK: - UIKit push bridge

struct CheckoutPushRepresentable<T: MPPaymentData.Kind>: UIViewControllerRepresentable {
    let checkout: MercadoPagoCheckout<T>
    let onResult: (MercadoPagoCheckoutResult<T>) -> Void

    func makeUIViewController(context _: Context) -> UINavigationController {
        let nav = UINavigationController()
        nav.setNavigationBarHidden(true, animated: false)
        self.checkout.push(to: nav, animated: false, onResult: self.onResult)
        return nav
    }

    func updateUIViewController(_: UINavigationController, context _: Context) {}
}
