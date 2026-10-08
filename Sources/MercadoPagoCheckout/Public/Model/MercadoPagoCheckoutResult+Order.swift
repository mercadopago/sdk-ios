//
//  MercadoPagoCheckoutResult+Order.swift
//  MercadoPagoSDK
//

extension MercadoPagoCheckoutResult {
    /// Result for a processed order: a rejected order is reported to the seller as an error.
    static func processedOrder(_ data: T, orderStatus: String) -> Self {
        guard orderStatus == "rejected" else { return .success(data) }
        return .error(MercadoPagoCheckoutError(
            code: .paymentRejected,
            localizedDescription: "Payment rejected",
            location: .orderProcess
        ))
    }
}
