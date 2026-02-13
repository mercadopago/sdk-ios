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
        HStack(alignment: .center, spacing: theme.spacings.xtiny) {
            
            switch configuration.type {
            case .radioButton(let selected):
                MPRadioButton(isOn: selected)
            case .none:
                EmptyView()
            }
            
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
                        }
                        
                        if let rightContent = configuration.rightContent {
                            rightContent
                        }
                    }
                }
                
                if let description = configuration.description {
                    description
                }
            }
        }
        .background(configuration.selectedButton)
        .padding(.horizontal, theme.spacings.micro)
        .padding(.vertical, theme.spacings.xtiny)
        .cornerRadius(theme.borderRadius.small)
    }
}
