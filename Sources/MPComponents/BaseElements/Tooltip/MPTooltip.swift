//
//  MPTooltip.swift
//  MPComponents
//

import SwiftUI
import MPFoundation

/// Tooltip component — displays short contextual text near a target element on interaction.
///
/// Width behavior is controlled by the caller:
/// - Hug (default): wraps content width (no maxWidth constraint applied)
/// - Fixed: pass an explicit `maxWidth`, e.g. 296pt per CVV tooltip spec
///
/// Dismiss-on-scroll is the caller's responsibility: observe the parent scroll offset and
/// toggle `isVisible` accordingly. Flowbook spec (PR #45) defines this for CVV tooltips.
///
/// - Parameters:
///   - text: Contextual label to display.
///   - maxWidth: Maximum width in points. Defaults to 296pt per Flowbook CVV tooltip spec (PR #45).
package struct MPTooltip: View {
    let text: String
    var maxWidth: CGFloat

    @Environment(\.checkoutTheme) private var theme: MPTheme

    package init(text: String, maxWidth: CGFloat = 296) {
        self.text = text
        self.maxWidth = maxWidth
    }

    package var body: some View {
        Text(text)
            .font(.init(theme.typography.body.small.default))
            .foregroundColor(theme.colors.text.inverse)
            .padding(.horizontal, theme.spacings.xmicro)
            .padding(.vertical, theme.spacings.xmicro)
            .frame(maxWidth: maxWidth, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: theme.borderRadius.tiny)
                    .fill(theme.colors.fill.inverse)
            )
    }
}

// MARK: - Previews

#if DEBUG
struct MPTooltip_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
                MPTooltip(text: "Label")
                    .previewDisplayName("Tooltip - Hug")
            }

            ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
                MPTooltip(
                    text: "Son 3 números que puedes encontrar en el dorso de la tarjeta o en la app de tu banco.",
                    maxWidth: 296
                )
                .previewDisplayName("Tooltip - CVV")
            }
        }
        .padding(16)
        .background(Color.white)
    }
}
#endif
