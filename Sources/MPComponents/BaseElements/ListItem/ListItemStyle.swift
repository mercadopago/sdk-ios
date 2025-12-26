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
    @Environment(\.isEnabled) var isEnabled: Bool

    @MainActor
    public func makeBody(configuration: ListItemStyleConfiguration) -> some View {
        HStack(alignment: .center, spacing: theme.spacings.micro) {
            if let leftImage = configuration.leftImage {
                leftImage
            }
            
            VStack(alignment: .leading, spacing: theme.spacings.xnano) {
                HStack(alignment: .top) {
                    configuration.title
                        .foregroundColor(titleColor(isSelected: configuration.isSelected))
                    
                    Spacer()
                    
                    HStack(spacing: theme.spacings.xmicro) {
                        if let textRight = configuration.textRight {
                            textRight
                                .foregroundColor(rightTextColor(isSelected: configuration.isSelected))
                        }
                        
                        if configuration.hasChevron {
                            Image(systemName: "chevron.right")
                                .foregroundColor(chevronColor(isSelected: configuration.isSelected))
                        }
                    }
                }
                
                if let description = configuration.description {
                    description
                        .foregroundColor(descriptionColor(isSelected: configuration.isSelected))
                }
            }
        }
        .padding(.horizontal, theme.spacings.micro)
        .padding(.vertical, theme.spacings.xtiny)
        .background(backgroundColor(isSelected: configuration.isSelected))
        .cornerRadius(theme.borderRadius.small)
    }
    
    // MARK: - Colors
    
    private func backgroundColor(isSelected: Bool) -> Color {
        return isSelected ? theme.colors.surface.active : theme.colors.surface.idle
    }
    
    private func titleColor(isSelected: Bool) -> Color {
        return theme.colors.text.primary
    }
    
    private func descriptionColor(isSelected: Bool) -> Color {
        if !isEnabled {
            return theme.colors.text.disabled
        }
        return theme.colors.text.primary
    }
    
    private func rightTextColor(isSelected: Bool) -> Color {
        if !isEnabled {
            return theme.colors.text.disabled
        }
        return theme.colors.text.secondary
    }
    
    private func chevronColor(isSelected: Bool) -> Color {
        if !isEnabled {
            return theme.colors.icon.disabled
        }
        return theme.colors.icon.accent
    }
}
