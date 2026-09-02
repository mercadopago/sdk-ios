import Foundation

package struct ClassifiedNativeError: Sendable, Equatable {
    package let operation: NativeErrorOperation
    package let code: NativeErrorCode
    package let statusCode: Int?
    package let requestCorrelationID: String?
    package let serviceTarget: NativeErrorServiceTarget?
    package let diagnosticCode: NativeErrorDiagnosticCode?

    package init(
        operation: NativeErrorOperation,
        code: NativeErrorCode,
        statusCode: Int? = nil,
        requestCorrelationID: String? = nil,
        serviceTarget: NativeErrorServiceTarget? = nil,
        diagnosticCode: NativeErrorDiagnosticCode? = nil
    ) {
        self.operation = operation
        self.code = code
        self.statusCode = statusCode.flatMap { (100...599).contains($0) ? $0 : nil }
        self.requestCorrelationID = requestCorrelationID.flatMap(Self.safeCorrelationID)
        self.serviceTarget = serviceTarget
        self.diagnosticCode = diagnosticCode
    }

    private static func safeCorrelationID(_ value: String) -> String? {
        guard (1...128).contains(value.utf8.count),
              value.unicodeScalars.allSatisfy({
                  CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._:-")
                      .contains($0)
              }) else { return nil }
        return value
    }
}

package struct PendingNativeError: Sendable {
    package let eventID: UUID
    package let occurredAt: Date
    package let environment: NativeErrorEnvironmentSnapshot
    package let error: ClassifiedNativeError
}

package struct NativeErrorReceipt: Sendable, Equatable {
    package let eventID: String
    package let shouldSendMelidata: Bool
}

package struct NativeErrorReport: Codable, Sendable, Equatable {
    package struct Source: Codable, Sendable, Equatable {
        package let sdkName: String
        package let sdkVersion: String
        package let hostPlatform: String
        package let sdkTechnology: String
        package let module: NativeErrorModule
        package let operation: NativeErrorOperation

        enum CodingKeys: String, CodingKey {
            case sdkName = "sdk_name"
            case sdkVersion = "sdk_version"
            case hostPlatform = "host_platform"
            case sdkTechnology = "sdk_technology"
            case module, operation
        }
    }

    package struct ErrorContext: Codable, Sendable, Equatable {
        package let code: NativeErrorCode
        package let category: NativeErrorCategory
        package let critical: Bool
        package let statusCode: Int?
        package let requestCorrelationID: String?
        package let serviceTarget: NativeErrorServiceTarget?
        package let diagnosticCode: NativeErrorDiagnosticCode?

        enum CodingKeys: String, CodingKey {
            case code, category, critical
            case statusCode = "status_code"
            case requestCorrelationID = "request_correlation_id"
            case serviceTarget = "service_target"
            case diagnosticCode = "diagnostic_code"
        }
    }

    package struct Device: Codable, Sendable, Equatable {
        package let osVersion: String

        enum CodingKeys: String, CodingKey { case osVersion = "os_version" }
    }

    package let eventID: String
    package let occurredAt: String
    package let source: Source
    package let siteID: String
    package let error: ErrorContext
    package let device: Device?

    enum CodingKeys: String, CodingKey {
        case eventID = "event_id"
        case occurredAt = "occurred_at"
        case source
        case siteID = "site_id"
        case error, device
    }

    package init(pending: PendingNativeError) {
        eventID = pending.eventID.uuidString.lowercased()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        occurredAt = formatter.string(from: pending.occurredAt)
        source = Source(
            sdkName: "openplatform_sdk_ios",
            sdkVersion: pending.environment.sdkVersion,
            hostPlatform: "ios",
            sdkTechnology: "native",
            module: pending.error.operation.module,
            operation: pending.error.operation
        )
        siteID = pending.environment.siteID
        error = ErrorContext(
            code: pending.error.code,
            category: pending.error.code.category,
            critical: pending.error.code.isCritical,
            statusCode: pending.error.statusCode,
            requestCorrelationID: pending.error.requestCorrelationID,
            serviceTarget: pending.error.serviceTarget,
            diagnosticCode: pending.error.diagnosticCode
        )
        device = pending.environment.osVersion.map(Device.init(osVersion:))
    }

}
