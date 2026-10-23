//
//  StatusScreenEventData.swift
//  MercadoPagoSDK
//

#if SWIFT_PACKAGE
    import MPAnalytics
#endif

struct StatusScreenEventData: AnalyticsEventData, Equatable, Sendable {
    enum Outcome: String, Encodable, Sendable {
        case started
        case success
        case failure
        case requested
        case dismissed
        case cancelled
    }

    enum Source: String, Encodable, Sendable {
        case back
        case unavailable
        case dismiss
    }

    let outcome: Outcome?
    let source: Source?
    let statusType: String?
    let canRetry: Bool?

    init(outcome: Outcome? = nil, source: Source? = nil, statusType: String? = nil, canRetry: Bool? = nil) {
        self.outcome = outcome
        self.source = source
        self.statusType = statusType
        self.canRetry = canRetry
    }

    func toDictionary() -> [String: any Sendable] {
        var data: [String: any Sendable] = [:]
        if let outcome {
            data["outcome"] = outcome.rawValue
        }
        if let source {
            data["source"] = source.rawValue
        }
        if let statusType {
            data["status_type"] = statusType
        }
        if let canRetry {
            data["can_retry"] = canRetry
        }
        return data
    }
}
