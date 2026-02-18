//
//  MercadoPagoCheckout.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 09/06/25.
//
import MPFoundation
import UIKit
import SwiftUI

public struct MercadoPagoCheckout: Sendable, Identifiable {
    public let id: UUID = UUID()
    
    public struct CheckoutAppearance: Sendable {
        public var style: UserInterfaceStyle = .automatic
        
        public var light: MPTheme
        
        public var dark: MPTheme
        
        @MainActor
        public init(
            style: UserInterfaceStyle = .automatic,
            light: MPTheme? = nil,
            dark: MPTheme? = nil
        ) {
            self.style = style
            self.light = light ?? MPLightTheme()
            self.dark = dark ?? MPLightTheme()
        }
    }
    
    public var theme: CheckoutAppearance
    public var checkoutConfiguration: CheckoutConfiguration
    
    @MainActor
    public init(theme: CheckoutAppearance = CheckoutAppearance(), checkoutConfiguration: CheckoutConfiguration) {
        self.theme = theme
        self.checkoutConfiguration = checkoutConfiguration
    }
    
    @MainActor
    @ViewBuilder
    public func show(
        onResult: @escaping (MercadoPagoCheckoutResult) -> Void
    ) -> some View {
        CardFormBrick(configuration: self, onResult: onResult)
    }

    @MainActor
    public func present(
        from viewController: UIViewController,
        animated: Bool = true,
        onResult: @escaping (MercadoPagoCheckoutResult) -> Void
    ) {
        let cardFormBrick = CardFormBrick(configuration: self, onResult: onResult)
        let hostingController = UIHostingController(rootView: cardFormBrick)
        hostingController.modalPresentationStyle = .fullScreen
        viewController.present(hostingController, animated: animated)
    }

    @MainActor
    public func push(
        to navigationController: UINavigationController,
        animated: Bool = true,
        onResult: @escaping (MercadoPagoCheckoutResult) -> Void
    ) {
        let cardFormBrick = CardFormBrick(configuration: self, onResult: onResult)
        let hostingController = UIHostingController(rootView: cardFormBrick)
        navigationController.pushViewController(hostingController, animated: animated)
    }
    
    public struct CheckoutConfiguration: Sendable {
        public var checkoutType: CheckoutType
        public var paymentMethod: [PaymentMethod]
    }
    
    public struct Payer: Sendable {
        var email: String
    }
    
    public struct CardFormConfiguration: Sendable {
        public var amount: Double?
        public var payer: Payer?
    }
    
    public enum CheckoutType: Sendable {
        case cardForm(cardFormConfiguration: CardFormConfiguration)
    }
    
    public enum PaymentMethod: Sendable {
        case card(cardTypes: [CardType], installment: Installment? = Installment())
        case pix
        case boleto
        case loan(installment: Installment? = Installment())
        
        public static var defaults: [PaymentMethod] {
            [
                .card(cardTypes: [.credit, .debit, .prepaid]),
                .pix,
                .boleto
            ]
            
        }
    }
    
    public struct Installment: Sendable {
        var minInstallments: Int
        var maxInstallments: Int
        
        public init(minInstallments: Int = 1, maxInstallments: Int = 180) {
            self.minInstallments = minInstallments
            self.maxInstallments = maxInstallments
        }
    }
    public enum CardType: Sendable {
        case credit
        case debit
        case prepaid
    }
    
    public class Builder {
        private var checkoutType: CheckoutType
        private var checkoutAppearance: CheckoutAppearance
        private var paymentMethods: [PaymentMethod]
        
        public init(checkoutType: CheckoutType, checkoutAppearance: CheckoutAppearance) {
            self.checkoutType = checkoutType
            self.checkoutAppearance = checkoutAppearance
            self.paymentMethods = PaymentMethod.defaults
        }
        
        @discardableResult
        public func setPaymentMethod(_ paymentMethods: [PaymentMethod] = PaymentMethod.defaults) -> Builder {
            self.paymentMethods = paymentMethods
            return self
        }
        
        @MainActor
        public func build() -> MercadoPagoCheckout {
            MercadoPagoCheckout(
                theme: checkoutAppearance,
                checkoutConfiguration: .init(
                    checkoutType: checkoutType,
                    paymentMethod: paymentMethods
                )
            )
        }
    }
}

