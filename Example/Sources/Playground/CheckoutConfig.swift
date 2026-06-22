//
//  CheckoutConfig.swift
//  Example
//
//  Playground configuration model: holds every checkout option in one place
//  and builds the correctly-typed MercadoPagoCheckout at trigger time.
//

import CoreMethods
import MercadoPagoCheckout
import SwiftUI

// MARK: - Option enums

enum CheckoutTypeOption: String, CaseIterable, Identifiable {
    case saveCard
    case cardTransaction
    case payment

    var id: String { rawValue }
    var title: String {
        switch self {
        case .saveCard: return "Save Card"
        case .cardTransaction: return "Card Transaction"
        case .payment: return "Payment"
        }
    }
}

enum PresentationMode: String, CaseIterable, Identifiable {
    case swiftUIShow
    case swiftUISheet
    case uikitPresent
    case uikitPush

    var id: String { rawValue }
    var title: String {
        switch self {
        case .swiftUIShow: return "SwiftUI (show)"
        case .swiftUISheet: return "SwiftUI (sheet)"
        case .uikitPresent: return "UIKit (present)"
        case .uikitPush: return "UIKit (push)"
        }
    }
}

enum AppearanceStyleOption: String, CaseIterable, Identifiable {
    case automatic
    case light
    case dark

    var id: String { rawValue }
    var title: String {
        switch self {
        case .automatic: return "Automatic"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

// MARK: - Display helpers for SDK / payment-method enums

extension MercadoPagoSDK.Country {
    /// Ordered list for the country picker (enum is not `CaseIterable`).
    static let pickerOptions: [MercadoPagoSDK.Country] = [
        .ARG, .BRA, .MEX, .COL, .CHL, .PER, .URY, .ECU, .PRY,
        .BOL, .CRI, .VEN, .DOM, .PAN, .GTM, .SLV, .HND, .NIC, .CUB
    ]
}

extension MPCardType {
    var displayName: String {
        switch self {
        case .credit: return "Credit"
        case .debit: return "Debit"
        case .prepaid: return "Prepaid"
        }
    }

    /// Stable, lowercase token for accessibility identifiers.
    var identifier: String {
        switch self {
        case .credit: return "credit"
        case .debit: return "debit"
        case .prepaid: return "prepaid"
        }
    }
}

/// Named brands exposed in the picker, paired with a friendly label.
struct BrandOption: Identifiable {
    let brand: MPCardBrand
    let label: String
    var id: String { self.label }

    static let all: [BrandOption] = [
        .init(brand: .visa, label: "Visa"),
        .init(brand: .master, label: "Mastercard"),
        .init(brand: .amex, label: "Amex"),
        .init(brand: .elo, label: "Elo"),
        .init(brand: .hipercard, label: "Hipercard"),
        .init(brand: .diners, label: "Diners"),
        .init(brand: .discover, label: "Discover"),
        .init(brand: .jcb, label: "JCB"),
        .init(brand: .maestro, label: "Maestro"),
        .init(brand: .unionPay, label: "UnionPay"),
        .init(brand: .cabal, label: "Cabal"),
        .init(brand: .naranja, label: "Naranja")
    ]
}

// MARK: - Config model

final class CheckoutConfig: ObservableObject {
    // SDK
    @Published var publicKey = ""
    @Published var country: MercadoPagoSDK.Country = .ARG

    // Checkout
    @Published var checkoutType: CheckoutTypeOption = .cardTransaction
    @Published var presentation: PresentationMode = .swiftUIShow
    @Published var appearance: AppearanceStyleOption = .automatic

    // Order (Card Transaction only)
    @Published var amount = 100.0
    @Published var email = "test@mp.com"
    @Published var orderId = "12345"
    @Published var clientToken = "seller_client_token"

    @Published var minInstallmentsText = ""
    @Published var maxInstallmentsText = ""

    var minInstallments: Int { Int(self.minInstallmentsText) ?? 1 }
    var maxInstallments: Int { Int(self.maxInstallmentsText) ?? 180 }

    /// Excluded card types
    @Published var excludedTypes: [MPCardType] = []

    /// Excluded brands
    @Published var excludedBrands: [MPCardBrand] = []

    // MARK: Toggle helpers

    func isTypeExcluded(_ type: MPCardType) -> Bool { self.excludedTypes.contains(type) }

    func setType(_ type: MPCardType, excluded: Bool) {
        if excluded {
            if !self.excludedTypes.contains(type) { self.excludedTypes.append(type) }
        } else {
            self.excludedTypes.removeAll { $0 == type }
        }
    }

    func isBrandExcluded(_ brand: MPCardBrand) -> Bool { self.excludedBrands.contains(brand) }

    func setBrand(_ brand: MPCardBrand, excluded: Bool) {
        if excluded {
            if !self.excludedBrands.contains(brand) { self.excludedBrands.append(brand) }
        } else {
            self.excludedBrands.removeAll { $0 == brand }
        }
    }

    // MARK: SDK reconfiguration

    func applySDKConfiguration() {
        MercadoPagoSDK.shared.setNewConfiguration(
            .init(publicKey: self.publicKey, country: self.country)
        )
    }

    // MARK: Builders

    private var paymentMethodConfigs: [MPPaymentMethodConfig] {
        [
            .card(
                excludedTypes: self.excludedTypes,
                excludedBrands: self.excludedBrands,
                installment: self.maxInstallments == 0 ? nil : MPInstallment(
                    minInstallments: self.minInstallments,
                    maxInstallments: self.maxInstallments
                )
            )
        ]
    }

    @MainActor
    private var checkoutAppearance: MPCheckoutAppearance {
        switch self.appearance {
        case .automatic: return MPCheckoutAppearance(style: .automatic)
        case .light: return MPCheckoutAppearance(style: .lightMode)
        case .dark: return MPCheckoutAppearance(style: .darkMode)
        }
    }

    @MainActor
    func makeCardSaveCheckout() -> MercadoPagoCheckout<MPPaymentData.CardSave> {
        MercadoPagoCheckout.Builder(
            checkoutType: .saveCard,
            checkoutAppearance: self.checkoutAppearance
        )
        .setPaymentMethodConfiguration(self.paymentMethodConfigs)
        .build()
    }

    @MainActor
    func makeCardTransactionCheckout() -> MercadoPagoCheckout<MPPaymentData.CardTransaction> {
        let order = MPOrder(
            orderId: orderId,
            clientToken: clientToken,
            amount: amount,
            payer: .init(email: email)
        )
        return MercadoPagoCheckout.Builder(
            checkoutType: .cardTransaction(order: order),
            checkoutAppearance: self.checkoutAppearance
        )
        .setPaymentMethodConfiguration(self.paymentMethodConfigs)
        .build()
    }

    @MainActor
    func makePaymentCheckout() -> MercadoPagoCheckout<MPPaymentData.Payment> {
        let order = MPOrder(
            orderId: orderId,
            clientToken: clientToken,
            amount: amount,
            payer: .init(email: email)
        )
        return MercadoPagoCheckout.Builder(
            checkoutType: .payment(order: order),
            checkoutAppearance: self.checkoutAppearance
        )
        .setPaymentMethodConfiguration(self.paymentMethodConfigs)
        .build()
    }
}
