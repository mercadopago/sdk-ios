//
//  CardFormViewModel.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 28/01/26.
//
import SwiftUI
import CoreMethods
import MPComponents

enum CardFormScreenState {
    case idle
    case loading
    case ready
}

@MainActor
final class CardFormViewModel: ObservableObject {

    // MARK: - Dependencies
    private let configuration: MercadoPagoCheckout.CheckoutConfiguration
    private let service: CheckoutServiceProtocol

    // MARK: - Formatters
    let cardNumberFormatter = CardNumberFormatter()
    let expirationDateFormatter = ExpirationDateFormatter()
    let securityCodeFormatter = SecurityCodeFormatter()

    var documentFormatter: DocumentFormatter {
        DocumentFormatter(mask: selectTypeDocument.getFormat())
    }

    // MARK: - Published State
    @Published var selectTypeDocument: IdentificationType = .init(name: "CPF")
    @Published var screenState: CardFormScreenState = .idle

    // MARK: - Init

    init(configuration: MercadoPagoCheckout.CheckoutConfiguration, service: CheckoutServiceProtocol = CheckoutService()) {
        self.configuration = configuration
        self.service = service
        self.screenState = .loading
    }
    
    // MARK: - Identification Types
    func loadIdentificationTypes() async {
        do {
            let types = try await service.identificationTypes()
            selectTypeDocument = types.first ?? selectTypeDocument
            screenState = .ready
        } catch {
            screenState = .ready
        }
    }
}
