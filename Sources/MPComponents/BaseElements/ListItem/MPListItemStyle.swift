//
//  ListItemStyle.swift
//  MPComponents
//
//  Created by [Your Name] on [Date].
//

import SwiftUI
import MPFoundation

package protocol MPListItemStyle: StyleProtocol, Identifiable where Configuration == MPListItemStyleConfiguration {}

package struct MPDefaultListItemStyle: MPListItemStyle {
    public var id: UUID = .init()

    @Environment(\.checkoutTheme) var theme: MPTheme

    @MainActor
    public func makeBody(configuration: MPListItemStyleConfiguration) -> some View {
        HStack(alignment: .center, spacing: theme.spacings.micro) {
            if let leftImage = configuration.leftImage {
                leftImage
            }
            
            VStack(alignment: .leading, spacing: theme.spacings.xnano) {
                HStack(alignment: .top) {
                    configuration.title
                    
                    Spacer()
                    
                    HStack(spacing: theme.spacings.xmicro) {
                        if let textRight = configuration.textRight {
                            textRight
                                .foregroundColor(rightTextColor(state: configuration.state))
                        }
                        
                        if let rightContent = configuration.rightContent {
                            rightContent
                                .foregroundColor(chevronColor(state: configuration.state))
                        }
                    }
                }
                
                if let description = configuration.description {
                    description
                        .foregroundColor(descriptionColor(state: configuration.state))
                }
            }
        }
        .background(configuration.selectedButton)
        .padding(.horizontal, theme.spacings.micro)
        .padding(.vertical, theme.spacings.xtiny)
        .background(backgroundColor(state: configuration.state))
        .cornerRadius(theme.borderRadius.small)
    }
    
    // MARK: - Colors
    
    private func backgroundColor(state: MPListItemState) -> Color {
        switch state {
        case .active: return theme.colors.surface.active
        default: return theme.colors.surface.idle
        }
    }
    
    
    private func descriptionColor(state: MPListItemState) -> Color {
        switch state {
        case .idle, .active:
            return theme.colors.text.primary
        case .disabled:
            return theme.colors.text.disabled
        }
    }
    
    private func rightTextColor(state: MPListItemState) -> Color {
        switch state {
        case .idle, .active:
            return theme.colors.text.primary
        case .disabled:
            return theme.colors.text.disabled
        }
    }
    
    private func chevronColor(state: MPListItemState) -> Color {
        switch state {
        case .idle, .active:
            return theme.colors.icon.accent
        case .disabled:
            return theme.colors.icon.disabled
        }
    }
}
