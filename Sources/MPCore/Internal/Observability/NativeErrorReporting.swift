package protocol ErrorObservabilityReporting: Sendable {
    func configure(sdkVersion: String, country: MercadoPagoSDK.Country)
    func capture(_ classifiedError: ClassifiedNativeError) -> NativeErrorReceipt
}

package protocol HasErrorObservability: Sendable {
    var errorObservability: ErrorObservabilityReporting { get }
}
