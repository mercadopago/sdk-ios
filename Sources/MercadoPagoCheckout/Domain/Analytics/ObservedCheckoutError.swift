import MPCore

struct ObservedCheckoutError: Error, @unchecked Sendable {
    let publicError: MercadoPagoCheckoutError
    let input: NativeErrorInput
}
