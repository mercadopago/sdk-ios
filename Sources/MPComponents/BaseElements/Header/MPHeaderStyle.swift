//
//  MPHeaderStyle.swift
//  MPComponents
//
//  Style protocol for MPHeader.
//

import MPFoundation
import SwiftUI

/// A style protocol for `MPHeader` enabling custom skins.
package protocol MPHeaderStyle: StyleProtocol, Identifiable where Configuration == MPHeaderStyleConfiguration {}

/// Default visual style for `MPHeader` using theme tokens.
/// Renders only the main header bar (back button + trailing actions).
/// The animated title is handled by `MPHeader` directly.
package struct MPDefaultHeaderStyle: MPHeaderStyle {
    package var id: UUID = .init()

    @Environment(\.checkoutTheme) var theme: MPTheme

    package init() {}

    @MainActor
    package func makeBody(configuration: MPHeaderStyleConfiguration) -> some View {
        HStack(spacing: self.theme.spacings.xmicro) {
            Button(action: configuration.onBack) {
                Image(systemName: Logos.arrowLeft)
            }
            .buttonStyle(MPBackButtonStyle())
            .accessibility(label: Text(MPStrings.Common.back))

            Text(configuration.title)
                .textStyle(.headingSmall())
                .lineLimit(1)
                .opacity(Double(configuration.inlineTitleOpacity))
                .frame(maxWidth: .infinity)

            if let trailing = configuration.trailingActions {
                trailing
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, self.theme.spacings.xtiny)
        .padding(.vertical, self.theme.spacings.micro)
        .background(self.headerBackgroundView(configuration))
        .overlay(
            GeometryReader { geo in
                Color.clear.preference(
                    key: MainHeaderHeightKey.self,
                    value: geo.size.height
                )
            }
        )
    }

    // MARK: - Background

    @ViewBuilder
    private func headerBackgroundView(
        _ configuration: MPHeaderStyleConfiguration
    ) -> some View {
        let epsilon: CGFloat = 0.00001

        if configuration.scrollOffset < -epsilon {
            self.theme.colors.fill.defaultOnScroll
        } else {
            Color.clear
        }
    }
}

// MARK: - PreferenceKey for Header Height

package struct MainHeaderHeightKey: PreferenceKey {
    package static let defaultValue: CGFloat = 0
    package static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Style Resolution

package extension MPHeaderStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedMPHeaderStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedMPHeaderStyle<Style: MPHeaderStyle>: View {
    let style: Style
    let configuration: Style.Configuration

    var body: some View {
        self.style.makeBody(configuration: self.configuration)
    }
}

// MARK: - Environment

private struct MPHeaderStyleKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: any MPHeaderStyle = MPDefaultHeaderStyle()
}

extension EnvironmentValues {
    var mpHeaderStyle: any MPHeaderStyle {
        get { self[MPHeaderStyleKey.self] }
        set { self[MPHeaderStyleKey.self] = newValue }
    }
}

package extension View {
    /// Sets the style for `MPHeader` within this view hierarchy.
    ///
    /// - Parameter style: The `MPHeaderStyle` to apply.
    func mpHeaderStyle(_ style: some MPHeaderStyle) -> some View {
        environment(\.mpHeaderStyle, style)
    }
}

// MARK: - Preview

#if DEBUG
    struct MPHeader_Previews: PreviewProvider {
        struct ExampleUsage: View {
            @Environment(\.presentationMode) var presentationMode

            var body: some View {
                MPHeader(
                    title: "Product Details",
                    onBack: {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                ) {
                    VStack(spacing: 0) {
                        ForEach(0 ..< 30) { line in
                            Text("Line \(line)")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.red))
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            }
        }

        static var previews: some View {
            NavigationView {
                MPHeader(
                    title: "Product",
                    onBack: {
                        print("Back tapped")
                    }
                ) {
                    VStack(spacing: 20) {
                        ForEach(0 ..< 30) { line in
                            Text("Line \(line)")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.red))
                                .cornerRadius(8)

                            NavigationLink(destination: ExampleUsage()) {
                                Text("Ir para o destino")
                            }
                        }
                    }
                    .padding()
                }
            }
            .loadMPFonts()
        }
    }
#endif
