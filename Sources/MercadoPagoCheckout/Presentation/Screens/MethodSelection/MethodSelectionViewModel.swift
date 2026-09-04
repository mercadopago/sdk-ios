//
//  MethodSelectionViewModel.swift
//  MercadoPagoSDK
//

import Combine
import MPAnalytics
import MPComponents
import MPCore

@MainActor
final class MethodSelectionViewModel: ObservableObject {
    let output: MethodSelectionOutput

    private let analytics: AnalyticsInterface
    private var analyticsTask: Task<Void, Never>?

    // MARK: - Published State

    @Published private(set) var selectedOptionId: String?
    @Published private(set) var isCtaEnabled = false

    // MARK: - Computed

    var listItemStyle: any MPListItemStyle { self.output.selectionType.listItemStyle }
    var trailingStyle: (any MPListItemTrailingStyle)? { self.output.selectionType.trailingStyle }
    var rowTrailing: MPListItemTrailing? { self.output.selectionType.rowTrailing }

    // MARK: - Init

    init(
        output: MethodSelectionOutput,
        analytics: AnalyticsInterface = CoreDependencyContainer.shared.analytics
    ) {
        self.output = output
        self.analytics = analytics
    }

    // MARK: - Actions

    @discardableResult
    func selectOption(_ optionId: String) -> MethodSelectionOutput.Option? {
        guard let option = self.output.options.first(where: { $0.id == optionId }) else { return nil }

        if self.output.selectionType == .chevron {
            self.trackSelection(option)
            return option
        }

        self.selectedOptionId = option.id
        self.isCtaEnabled = true
        return nil
    }

    @discardableResult
    func confirmSelection() -> MethodSelectionOutput.Option? {
        guard let selectedId = self.selectedOptionId,
              let option = self.output.options.first(where: { $0.id == selectedId }) else { return nil }

        self.selectedOptionId = nil
        self.isCtaEnabled = false
        self.trackSelection(option)
        return option
    }

    func goBack() {
        self.enqueueAnalytics { [analytics = self.analytics] in
            await analytics.trackEvent(MethodSelectionAnalyticsPath.back).send()
        }
    }

    // MARK: - Analytics

    func trackInitialize() {
        let eventData = MethodSelectionInitializeEventData(
            optionsCount: self.output.options.count,
            selectionType: self.output.selectionType.analyticsValue
        )
        self.enqueueAnalytics { [analytics = self.analytics] in
            await analytics.trackEvent(MethodSelectionAnalyticsPath.initialize)
                .setEventData(eventData)
                .send()
        }
    }

    private func trackSelection(_ option: MethodSelectionOutput.Option) {
        let eventData = MethodSelectionSelectedEventData(
            paymentMethodId: option.id,
            selectionType: self.output.selectionType.analyticsValue
        )
        self.enqueueAnalytics { [analytics = self.analytics] in
            await analytics.trackEvent(MethodSelectionAnalyticsPath.selected)
                .setEventData(eventData)
                .send()
        }
    }

    private func enqueueAnalytics(_ block: @escaping @Sendable () async -> Void) {
        let previous = self.analyticsTask
        self.analyticsTask = Task {
            await previous?.value
            await block()
        }
    }
}
