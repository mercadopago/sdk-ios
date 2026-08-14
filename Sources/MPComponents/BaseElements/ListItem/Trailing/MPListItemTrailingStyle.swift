//
//  MPListItemTrailingStyle.swift
//  MPComponents
//
//  Created by Guilherme Prata Costa on 24/02/26.
//

import MPFoundation
import SwiftUI

// MARK: - Protocol

package protocol MPListItemTrailingStyle: StyleProtocol, Identifiable
    where Configuration == MPListItemTrailingStyleConfiguration {}

// MARK: - Configuration

package struct MPListItemTrailingStyleConfiguration {
    package let text: String?
    package let textColor: TextStyleColorType?
    package let action: (() -> Void)?
}

// MARK: - Text-only style (default)

package struct MPTrailingTextStyle: MPListItemTrailingStyle {
    package var id: UUID = .init()

    package init() {}

    @MainActor
    package func makeBody(configuration: MPListItemTrailingStyleConfiguration) -> some View {
        if let text = configuration.text {
            Text(text)
                .textStyle(.large(colorType: configuration.textColor ?? .primary))
        }
    }
}

// MARK: - Text + Icon style

package struct MPTrailingTextIconStyle: MPListItemTrailingStyle {
    package var id: UUID = .init()

    let icon: Image

    package init(icon: Image) {
        self.icon = icon
    }

    @Environment(\.checkoutTheme) private var theme: MPTheme

    @MainActor
    package func makeBody(configuration: MPListItemTrailingStyleConfiguration) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: self.theme.spacings.xmicro) {
            if let text = configuration.text {
                Text(text)
                    .textStyle(.large(colorType: configuration.textColor ?? .primary))
            }
            self.icon
                .foregroundColor(self.theme.colors.icon.accent)
        }
    }
}

// MARK: - Action button style

package struct MPTrailingActionButtonStyle: MPListItemTrailingStyle {
    package var id: UUID = .init()

    package init() {}

    @MainActor
    package func makeBody(configuration: MPListItemTrailingStyleConfiguration) -> some View {
        if let text = configuration.text {
            if let action = configuration.action {
                Button(text, action: action)
                    .mpButtonStyle(variant: .quiet, size: .small)
                    .fixedSize()
            } else {
                Text(text)
                    .textStyle(.large(colorType: configuration.textColor ?? .primary))
            }
        }
    }
}

// MARK: - Convenience extensions

extension MPListItemTrailingStyle where Self == MPTrailingTextStyle {
    /// Text-only trailing: `.listItemTrailingStyle(.text)`
    package static var text: MPTrailingTextStyle {
        MPTrailingTextStyle()
    }
}

extension MPListItemTrailingStyle where Self == MPTrailingTextIconStyle {
    /// Text + icon trailing: `.listItemTrailingStyle(.textIcon(Image(...)))`
    package static func textIcon(_ icon: Image) -> MPTrailingTextIconStyle {
        MPTrailingTextIconStyle(icon: icon)
    }
}

extension MPListItemTrailingStyle where Self == MPTrailingActionButtonStyle {
    /// Action button trailing: `.listItemTrailingStyle(.actionButton)`
    package static var actionButton: MPTrailingActionButtonStyle {
        MPTrailingActionButtonStyle()
    }
}

// MARK: - Environment

private struct ListItemTrailingStyleKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: (any MPListItemTrailingStyle)? = nil
}

extension EnvironmentValues {
    var listItemTrailingStyle: (any MPListItemTrailingStyle)? {
        get { self[ListItemTrailingStyleKey.self] }
        set { self[ListItemTrailingStyleKey.self] = newValue }
    }
}

// MARK: - Resolver

package extension MPListItemTrailingStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedListItemTrailingStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedListItemTrailingStyle<Style: MPListItemTrailingStyle>: View {
    let style: Style
    let configuration: Style.Configuration

    var body: some View {
        self.style.makeBody(configuration: self.configuration)
    }
}

// MARK: - View modifier

package extension View {
    /// Sets the trailing style for `MPListItem` views within this view.
    /// Outermost caller wins — inner modifiers are ignored if an ancestor already set a style.
    func listItemTrailingStyle(_ style: some MPListItemTrailingStyle) -> some View {
        transformEnvironment(\.listItemTrailingStyle) { current in
            if current == nil {
                current = style
            }
        }
    }
}
