//
//  MPSellerInfo.swift
//  MercadoPagoSDK
//

/// Store details displayed at the top of the review and confirm screen.
///
/// Pass an `MPSellerInfo` to `withReviewAndConfirm(seller:onEmailChangeRequested:)` on the
/// checkout builder to show your store's name and logo while the buyer reviews the payment.
/// Both fields are optional and independent — supply only the ones you want displayed, or omit
/// the seller entirely to render the screen without the store section.
///
/// Products and discount coupons are not part of this type: the SDK resolves them from the order
/// through the backend.
///
/// ```swift
/// let checkout = MercadoPagoCheckout.Builder(checkoutType: .payment(order: order))
///     .withReviewAndConfirm(
///         seller: MPSellerInfo(
///             name: "Adidas Store",
///             logoUrl: "https://cdn.example.com/adidas-logo.png"
///         )
///     )
///     .build()
/// ```
public struct MPSellerInfo: Hashable, Sendable {
    /// The store name shown above the payment details.
    public let name: String?

    /// The URL of the store logo shown next to the name.
    public let logoUrl: String?

    /// Creates the store details to display on the review and confirm screen.
    ///
    /// - Parameters:
    ///   - name: The store name shown above the payment details.
    ///   - logoUrl: The URL of the store logo shown next to the name.
    public init(
        name: String? = nil,
        logoUrl: String? = nil
    ) {
        self.name = name
        self.logoUrl = logoUrl
    }
}
