package struct NativeObservabilityConfiguration: Sendable, Equatable {
    package let sdkVersion: String
    package let siteID: String

    package init(sdkVersion: String, siteID: String) {
        self.sdkVersion = sdkVersion
        self.siteID = siteID
    }
}

package protocol ErrorObservabilityReporting: Sendable {
    func configure(_ configuration: NativeObservabilityConfiguration) async
    func capture(operation: NativeErrorOperation, input: NativeErrorInput) async -> NativeErrorReceipt
}

package protocol HasErrorObservability: Sendable {
    var errorObservability: any ErrorObservabilityReporting { get }
}
