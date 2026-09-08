package protocol ErrorObservabilityReporting: Sendable {
    func configure(sdkVersion: String, country: MercadoPagoSDK.Country)
    func capture(operation: NativeErrorOperation, input: NativeErrorInput) -> NativeErrorReceipt
}

package protocol HasErrorObservability: Sendable {
    var errorObservability: ErrorObservabilityReporting { get }
}
