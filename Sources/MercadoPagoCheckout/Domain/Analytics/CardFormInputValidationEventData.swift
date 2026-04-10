import MPAnalytics

struct CardFormInputValidationEventData: AnalyticsEventData {
    let field: String
    let isInputValid: Bool

    func toDictionary() -> [String: any Sendable] {
        [
            "field": self.field,
            "is_input_valid": self.isInputValid
        ]
    }
}
