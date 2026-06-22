//
//  MPFixedFooterButtonData.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 10/03/26.
//

/// Configuration for the call-to-action button displayed inside `MPFooter`.
///
/// ```swift
/// MPFixedFooterButtonData(text: "Pay") {
///     checkout.submit()
/// }
/// ```
package struct MPFixedFooterButtonData {
    /// Label text displayed on the button.
    var text: String
    /// Visual variant of the button. Defaults to `.loud`.
    var style: MPButtonStyle.Variant = .loud
    /// Optional icon displayed to the left of the label.
    var icon: Logos.Icon?
    /// Closure invoked when the button is tapped.
    var onClick: () async -> Void

    package init(
        text: String,
        style: MPButtonStyle.Variant = .loud,
        icon: Logos.Icon? = nil,
        onClick: @escaping () async -> Void
    ) {
        self.text = text
        self.style = style
        self.icon = icon
        self.onClick = onClick
    }
}
