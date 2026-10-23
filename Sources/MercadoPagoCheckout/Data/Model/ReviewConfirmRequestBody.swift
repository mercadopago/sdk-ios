//
//  ReviewConfirmRequestBody.swift
//  MercadoPagoSDK
//

/// Body sent to `POST /review_confirm`. The backend uses it to resolve the payment method
/// display, products, coupon and installment interest, and to decide whether the payer email row
/// is editable.
struct ReviewConfirmRequestBody: Encodable {
    let orderId: String
    let paymentMethodType: String
    let paymentMethodId: String
    let issuerId: String?
    /// First 6-8 digits of the card, used by the backend to resolve the issuer name.
    let bin: String?
    let lastFourDigits: String?
    let installments: Int?
    let installmentAmount: String?
    /// `true` when the integrator configured `onEmailChangeRequested` on the builder.
    let emailChangeEnabled: Bool
    let sellerInfo: SellerInfo?

    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case paymentMethodType = "payment_method_type"
        case paymentMethodId = "payment_method_id"
        case issuerId = "issuer_id"
        case bin
        case lastFourDigits = "last_four_digits"
        case installments
        case installmentAmount = "installment_amount"
        case emailChangeEnabled = "email_change_enabled"
        case sellerInfo = "seller_info"
    }

    struct SellerInfo: Encodable {
        let name: String?
        let iconUrl: String?

        enum CodingKeys: String, CodingKey {
            case name
            case iconUrl = "icon_url"
        }
    }
}
