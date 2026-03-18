//
//  CardFormBrickViewModel.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 18/03/26.
//
import Foundation

@MainActor
final class CardFormBrickViewModel: ObservableObject {
    enum ScreenState {
        case loading
        case ready(CardFormInitializationOutput)
    }

    // MARK: - Published State

    @Published private(set) var screenState: ScreenState = .loading

    // MARK: - Dependencies

    private let configuration: MercadoPagoCheckout.CheckoutConfiguration
    private let initializeUseCase: InitializeCardFormUseCase

    // MARK: - Init

    init(
        configuration: MercadoPagoCheckout.CheckoutConfiguration,
        initializeUseCase: InitializeCardFormUseCase = InitializeCardFormUseCase()
    ) {
        self.configuration = configuration
        self.initializeUseCase = initializeUseCase
    }

    // MARK: - Initialization

    func load() async throws(MercadoPagoCheckoutError) {
        let config = self.extractCardFormConfig()
        let result = try await self.initializeUseCase.execute(config: config)
        self.screenState = .ready(result)
    }

    // MARK: - Private

    private func extractCardFormConfig() -> MercadoPagoCheckout.CardFormConfiguration {
        if case let .cardForm(config) = configuration.type {
            return config
        }
        return MercadoPagoCheckout.CardFormConfiguration()
    }
}
