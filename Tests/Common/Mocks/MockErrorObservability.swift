//
//  MockErrorObservability.swift
//  MercadoPagoSDK-iOS
//
//  Created by Mercado Pago on 22/09/26.
//

import MPCore

package actor MockErrorObservability: ErrorObservabilityReporting {
    package struct Capture: Sendable, Equatable {
        package let operation: NativeErrorOperation
        package let input: NativeErrorInput
    }

    private let receipt: NativeErrorReceipt
    package private(set) var configurations: [NativeObservabilityConfiguration] = []
    package private(set) var captures: [Capture] = []

    package init(
        eventID: String = "00000000-0000-4000-8000-000000000001",
        shouldSendMelidata: Bool = true
    ) {
        self.receipt = .init(eventID: eventID, shouldSendMelidata: shouldSendMelidata)
    }

    package func configure(_ configuration: NativeObservabilityConfiguration) {
        self.configurations.append(configuration)
    }

    package func capture(operation: NativeErrorOperation, input: NativeErrorInput) -> NativeErrorReceipt {
        self.captures.append(.init(operation: operation, input: input))
        return self.receipt
    }
}
