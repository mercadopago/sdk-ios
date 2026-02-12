//
//  MercadoPagoCheckout.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 09/06/25.
//
import SwiftUI
import MPFoundation

public struct MercadoPagoCheckout {

    // MARK: - Theme

    public struct Theme {
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

    // MARK: - Properties

    let checkoutType: CheckoutType
    let theme: Theme
    let reviewAndConfirm: Bool
    let onResult: @MainActor @Sendable (CheckoutResult) -> Void

    // MARK: - Builder

    /// Builder para configurar e construir uma instância de `MercadoPagoCheckout`.
    ///
    /// Parâmetros obrigatórios são passados no `init`, opcionais via API fluente.
    ///
    /// ```swift
    /// let checkout = MercadoPagoCheckout.Builder(.cardForm, theme: theme)
    ///     .reviewAndConfirm(true)
    ///     .onResult { result in
    ///         // handle result
    ///     }
    ///     .build()
    /// ```
    @MainActor
    public final class Builder {

        // Obrigatórios
        private let checkoutType: CheckoutType
        private let theme: Theme

        // Opcionais
        private var reviewAndConfirm: Bool = true
        private var onResult: (@MainActor @Sendable (CheckoutResult) -> Void)?

        /// Inicializa o builder com os parâmetros obrigatórios.
        /// - Parameters:
        ///   - checkoutType: Tipo do checkout (ex: `.cardForm`).
        ///   - theme: Tema visual do checkout.
        public init(_ checkoutType: CheckoutType, theme: Theme) {
            self.checkoutType = checkoutType
            self.theme = theme
        }

        /// Habilita ou desabilita a tela de Revisa e Confirma.
        /// - Parameter enabled: `true` para incluir a etapa (default), `false` para pular.
        @discardableResult
        public func reviewAndConfirm(_ enabled: Bool) -> Builder {
            self.reviewAndConfirm = enabled
            return self
        }

        /// Define o callback de resultado do checkout.
        /// O callback é executado no `MainActor`, garantindo segurança para atualizações de UI.
        /// - Parameter handler: Closure chamada com o resultado do checkout.
        @discardableResult
        public func onResult(
            _ handler: @escaping @MainActor @Sendable (CheckoutResult) -> Void
        ) -> Builder {
            self.onResult = handler
            return self
        }

        /// Constrói a configuração do checkout.
        /// Use `createView()` ou `createViewController()` no objeto retornado para instanciar a UI.
        public func build() -> MercadoPagoCheckout {
            let defaultHandler: @MainActor @Sendable (CheckoutResult) -> Void = { @MainActor _ in }
            return MercadoPagoCheckout(
                checkoutType: checkoutType,
                theme: theme,
                reviewAndConfirm: reviewAndConfirm,
                onResult: onResult ?? defaultHandler
            )
        }
    }

    // MARK: - View Factory

    /// Cria o fluxo completo do checkout como uma SwiftUI `View`.
    ///
    /// ```swift
    /// .sheet(isPresented: $show) {
    ///     checkout.createView()
    /// }
    /// ```
    @MainActor
    @ViewBuilder
    public func createView() -> some View {
        CheckoutFlowView(checkout: self)
    }

    /// Cria o fluxo completo do checkout como um `UIViewController`.
    ///
    /// ```swift
    /// let vc = checkout.createViewController()
    /// vc.modalPresentationStyle = .fullScreen
    /// present(vc, animated: true)
    /// ```
    @MainActor
    public func createViewController() -> UIViewController {
        UIHostingController(rootView: CheckoutFlowView(checkout: self))
    }
}
