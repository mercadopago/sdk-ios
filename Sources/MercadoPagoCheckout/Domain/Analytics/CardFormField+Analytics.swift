extension CardFormField {
    var analyticsValue: String {
        switch self {
        case .cardNumber: return "card_number"
        case .cardHolder: return "card_holder"
        case .expirationDate: return "expiration_date"
        case .securityCode: return "cvv"
        case .document: return "document"
        }
    }
}
