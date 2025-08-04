//
//  ListItemStyle.swift
//  MPComponents
//
//  Created by [Your Name] on [Date].
//

import SwiftUI
import MPFoundation


package protocol ListItemStyle: StyleProtocol, Identifiable where Configuration == ListItemStyleConfiguration {}

package struct DefaultListItemStyle: ListItemStyle {
    public var id: UUID = .init()

    @Environment(\.checkoutTheme) var theme: MPTheme

    @MainActor
    public func makeBody(configuration: ListItemStyleConfiguration) -> some View {
        VStack {
            HStack(spacing: theme.spacings.s) {
                configuration.toggle
                
                configuration.primaryText

                
                Spacer()
                
                if configuration.secondaryText != nil {
                    configuration.secondaryText
                }
                
                if configuration.badge != nil {
                    configuration.badge
                }
                
            }
            .padding(theme.spacings.xs)
            
            Divider()
        }
    }
}
