//
//  MPFeedbackStyleConfiguration.swift
//  MercadoPagoSDK
//

import SwiftUI

package struct MPFeedbackStyleConfiguration {
    package struct Title: View {
        package let body: AnyView
    }

    package let iconSource: MPIconSource
    package let iconColor: MPIconColor
    package let title: Title

    @MainActor
    package init(iconSource: MPIconSource, iconColor: MPIconColor, title: some View) {
        self.iconSource = iconSource
        self.iconColor = iconColor
        self.title = Title(body: AnyView(title))
    }
}
