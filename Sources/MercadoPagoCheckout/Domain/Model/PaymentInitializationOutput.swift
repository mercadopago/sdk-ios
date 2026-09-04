//
//  PaymentInitializationOutput.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 01/06/26.
//

import Foundation

/// Data that drives the payment method selection screen.
struct PaymentInitializationOutput: Equatable {
    let headerTitle: String
    let sections: [Section]
    let footer: Footer

    struct Footer: Equatable {
        let totalLabel: String
        let totalAmount: String
    }

    /// A titled group of payment options (e.g. "Mercado Pago", "Outros meios de pagamento").
    struct Section: Identifiable, Equatable {
        let id: String
        let title: String
        let items: [Item]
    }

    /// A single selectable payment option.
    struct Item: Identifiable, Equatable {
        let id: String
        let title: String
        let description: String?
        let icon: Icon
        let route: String
        let cardData: CardData?
        /// Present on the `ticket` method when the BFF decides to show the Off Payment List screen.
        let screen: MethodSelectionOutput?

        init(
            id: String,
            title: String,
            description: String?,
            icon: Icon,
            route: String,
            cardData: CardData? = nil,
            screen: MethodSelectionOutput? = nil
        ) {
            self.id = id
            self.title = title
            self.description = description
            self.icon = icon
            self.route = route
            self.cardData = cardData
            self.screen = screen
        }

        /// Source of the leading thumbnail icon.
        enum Icon: Equatable {
            case remote(URL?)
            case system(String)
        }

        struct CardData: Equatable {
            let paymentMethodId: String
            let paymentTypeId: String
            let issuerId: Int
            let securityCodeScreen: SecurityCodeScreenOutput?
            let bin: String?
            /// Last 4 digits of the card, used by the review and confirm screen's request.
            let lastFourDigits: String?

            init(
                paymentMethodId: String,
                paymentTypeId: String,
                issuerId: Int,
                securityCodeScreen: SecurityCodeScreenOutput? = nil,
                bin: String? = nil,
                lastFourDigits: String? = nil
            ) {
                self.paymentMethodId = paymentMethodId
                self.paymentTypeId = paymentTypeId
                self.issuerId = issuerId
                self.securityCodeScreen = securityCodeScreen
                self.bin = bin
                self.lastFourDigits = lastFourDigits
            }
        }
    }
}

extension PaymentInitializationOutput {
    // TODO: Replace this mock with the real payment initialization response once the network call exists.
    private static func resource(_ name: String) -> URL? {
        URL(string: "https://http2.mlstatic.com/storage/mobile-on-demand-resources//image/\(name)")
    }

    static var mock: PaymentInitializationOutput {
        PaymentInitializationOutput(
            headerTitle: "Escolha como pagar",
            sections: [
                Section(
                    id: "mercado_pago",
                    title: "Mercado Pago",
                    items: [
                        Item(
                            id: "account_money",
                            title: "Saldo em conta ou cartões salvos",
                            description: nil,
                            icon: .remote(resource("cho_off-mercadopago_xxxhdpi")),
                            route: "account_money"
                        ),
                        Item(
                            id: "credit_line",
                            title: "Linha de Crédito",
                            description: nil,
                            icon: .remote(resource("cho_off-mercadopago_xxxhdpi")),
                            route: "credit_line"
                        )
                    ]
                ),
                Section(
                    id: "other_payment_methods",
                    title: "Outros meios de pagamento",
                    items: [
                        Item(
                            id: "saved_card",
                            title: "{Banco} •••• 1234",
                            description: "Visa Crédito",
                            icon: .remote(resource("cho_off-visa_xxxhdpi")),
                            route: "saved_card"
                        ),
                        Item(
                            id: "pix",
                            title: "Pix",
                            description: nil,
                            icon: .remote(resource("cho_off-pix_xxxhdpi")),
                            route: "pix"
                        ),
                        Item(
                            id: "boleto",
                            title: "Boleto",
                            description: nil,
                            icon: .remote(resource("cho_off-boleto_xxxhdpi")),
                            route: "boleto"
                        ),
                        Item(
                            id: "new_card",
                            title: "Novo cartão",
                            description: "Crédito ou pré-pago",
                            icon: .remote(resource("cho_off-add-card_xxxhdpi")),
                            route: "card_form"
                        )
                    ]
                )
            ],
            footer: .init(totalLabel: "Total", totalAmount: "$ 15")
        )
    }
}
