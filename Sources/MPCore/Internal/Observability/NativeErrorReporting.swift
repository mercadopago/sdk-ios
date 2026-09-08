package protocol ErrorObservabilityReporting: Sendable {
    func configure(sdkVersion: String, country: MercadoPagoSDK.Country)
    func capture(operation: NativeErrorOperation, input: NativeErrorInput) -> NativeErrorReceipt

    // Transitional compatibility for the existing stacked adapters. Removed once both adapters emit neutral input.
    func capture(_ classifiedError: ClassifiedNativeError) -> NativeErrorReceipt
}

package extension ErrorObservabilityReporting {
    func capture(operation: NativeErrorOperation, input: NativeErrorInput) -> NativeErrorReceipt {
        capture(NativeErrorClassifier.classify(operation: operation, input: input))
    }
}

package protocol HasErrorObservability: Sendable {
    var errorObservability: ErrorObservabilityReporting { get }
}
