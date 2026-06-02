//
//  Logos.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 22/08/25.
//

package enum Logos: Equatable {
    package enum Feedback: String, Sendable {
        case positive = "Feedback-Check"
        case negative = "Feedback-Minus"
        case caution = "Feedback-Caution"
        case informative = "Feedback-info"

        package var assetName: String { rawValue }
    }

    package static let errorFilled = "Error-Filled"
    package static let close = "Close"
    package static let arrowLeft = "arrow.left"
    package static let questionMark = "questionmark.circle"
    package static let chevronRight = "chevron.right"
}
