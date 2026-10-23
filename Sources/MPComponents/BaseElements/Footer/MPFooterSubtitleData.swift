//
//  MPFooterSubtitleData.swift
//  MercadoPagoSDK
//

import Foundation

/// Structured subtitle content rendered by `MPFooter`.
///
/// Use multiple segments when parts of the subtitle need different semantic colors.
package struct MPFooterSubtitleData: Equatable {
    package struct Segment: Equatable, Identifiable {
        package let id: UUID = .init()
        let text: String
        let color: TextStyleColorType

        package init(text: String, color: TextStyleColorType = .secondary) {
            self.text = text
            self.color = color
        }
    }

    let segments: [Segment]

    package init(segments: [Segment]) {
        self.segments = segments
    }

    package init(text: String, color: TextStyleColorType = .secondary) {
        self.segments = [.init(text: text, color: color)]
    }
}
