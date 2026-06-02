//
//  MPListItemStyle.swift
//  MPComponents
//
//  Created by [Your Name] on [Date].
//

import MPFoundation
import SwiftUI

package protocol MPListItemStyle: StyleProtocol, Identifiable where Configuration == MPListItemStyleConfiguration {}

// MARK: - Convenience extensions

extension MPListItemStyle where Self == MPDefaultListItemStyle {
    /// Default plain style: `.listItemStyle(.default)`
    package static var `default`: MPDefaultListItemStyle {
        MPDefaultListItemStyle()
    }
}

extension MPListItemStyle where Self == MPListRowRadioStyle {
    /// Radio button style: `.listItemStyle(.radioButton)`
    package static var radioButton: MPListRowRadioStyle {
        MPListRowRadioStyle()
    }
}

extension MPListItemStyle where Self == MPListRowPickStyle {
    /// Pick/selection style: `.listItemStyle(.pick)`
    package static var pick: MPListRowPickStyle {
        MPListRowPickStyle()
    }
}

extension MPListItemStyle where Self == MPListRowChevronStyle {
    /// Chevron navigation style: `.listItemStyle(.chevron)`
    package static var chevron: MPListRowChevronStyle {
        MPListRowChevronStyle()
    }
}

package struct MPDefaultListItemStyle: MPListItemStyle {
    public var id: UUID = .init()

    @Environment(\.checkoutTheme) var theme: MPTheme

    @MainActor
    public func makeBody(configuration: MPListItemStyleConfiguration) -> some View {
        let hasDescription = configuration.description != nil

        HStack(alignment: hasDescription ? .top : .center, spacing: self.theme.spacings.xtiny) {
            if let leftImage = configuration.leftImage {
                leftImage
            }

            VStack(alignment: .leading, spacing: self.theme.spacings.xnano) {
                if let header = configuration.header {
                    header
                }
                if let title = configuration.title {
                    title
                        .textStyle(.largeSemibold())
                }
                if let description = configuration.description {
                    description
                }
            }

            Spacer()

            if let trailing = configuration.trailing {
                trailing
            }
        }
        .padding(.horizontal, self.theme.spacings.micro)
        .padding(.vertical, self.theme.spacings.xtiny)
        .cornerRadius(self.theme.borderRadius.small)
    }
}
