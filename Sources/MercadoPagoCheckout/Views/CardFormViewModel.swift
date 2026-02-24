//
//  CardFormViewModel.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 28/01/26.
//
import SwiftUI
import CoreMethods
import MPComponents

@MainActor
final class CardFormViewModel: ObservableObject {

    // MARK: - Dependencies
    private let configuration: MercadoPagoCheckout.CheckoutConfiguration
    private let service: CheckoutServiceProtocol

    // MARK: - Formatters
    let cardNumberFormatter = CardNumberFormatter()
    let expirationDateFormatter = ExpirationDateFormatter()
    let securityCodeFormatter = SecurityCodeFormatter()

    // MARK: - Published State
    @Published var selectTypeDocument: IdentificationType = .init(name: "CPF")
    @Published var isLoadingIdentificationTypes: Bool = true //Validar comportamento com UX

    // MARK: - Init

    init(configuration: MercadoPagoCheckout.CheckoutConfiguration, service: CheckoutServiceProtocol = CheckoutService()) {
        self.configuration = configuration
        self.service = service
    }
    
    // MARK: - Identification Types
    func loadIdentificationTypes() async {
        do {
            let types = try await service.identificationTypes()
            isLoadingIdentificationTypes = false
            selectTypeDocument = types.first ?? selectTypeDocument
        } catch {
            isLoadingIdentificationTypes = false
        }
    }
}
