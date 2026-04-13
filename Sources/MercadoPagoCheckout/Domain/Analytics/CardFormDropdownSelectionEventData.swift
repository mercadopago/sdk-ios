import MPAnalytics

enum CardFormDropdownType {
    case documentType

    var analyticsValue: String {
        switch self {
        case .documentType: return "document_type"
        }
    }
}

struct CardFormDropdownSelectionEventData: AnalyticsEventData {
    let dropdownSelectionType: String

    func toDictionary() -> [String: any Sendable] {
        ["dropdown_selection_type": self.dropdownSelectionType]
    }
}
