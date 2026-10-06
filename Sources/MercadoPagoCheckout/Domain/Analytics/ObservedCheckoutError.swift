import MPCore

struct ObservedCheckoutError: Error {
    let publicError: MercadoPagoCheckoutError
    let input: NativeErrorInput
}
