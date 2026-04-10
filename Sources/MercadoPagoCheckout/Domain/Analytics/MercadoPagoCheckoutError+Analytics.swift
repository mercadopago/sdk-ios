extension MercadoPagoCheckoutError {
    var analyticsErrorType: String {
        switch code {
        case .networkConnectionFailed, .networkTimeout:
            return "network_error"
        case .serviceError:
            return "service_error"
        case .integrationError:
            return "integration_error"
        default:
            return "unknown_error"
        }
    }
}
