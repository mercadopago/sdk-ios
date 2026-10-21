//
//  MPFeedback.swift
//  MercadoPagoSDK
//

import SwiftUI

package struct MPFeedback: View {
    private let title: String
    private let iconSource: MPIconSource
    private let iconColor: MPIconColor

    @Environment(\.mpFeedbackStyle) private var style: any MPFeedbackStyle

    package init(
        title: String,
        iconSource: MPIconSource,
        iconColor: MPIconColor = .secondary
    ) {
        self.title = title
        self.iconSource = iconSource
        self.iconColor = iconColor
    }

    package var body: some View {
        let configuration = MPFeedbackStyleConfiguration(
            iconSource: self.iconSource,
            iconColor: self.iconColor,
            title: Text(self.title)
        )
        AnyView(self.style.resolve(configuration: configuration))
            .accessibilityElement(children: .combine)
            .accessibility(label: Text(self.title))
    }
}
