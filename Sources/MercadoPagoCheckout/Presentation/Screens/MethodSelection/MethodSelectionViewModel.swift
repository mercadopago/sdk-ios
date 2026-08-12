//
//  MethodSelectionViewModel.swift
//  MercadoPagoSDK
//

import Combine
import MPComponents

@MainActor
final class MethodSelectionViewModel: ObservableObject {
    let output: MethodSelectionOutput

    // MARK: - Published State

    @Published private(set) var selectedOptionId: String?
    @Published private(set) var isCtaEnabled = false

    // MARK: - Computed

    var listItemStyle: any MPListItemStyle { self.output.selectionType.listItemStyle }
    var trailingStyle: (any MPListItemTrailingStyle)? { self.output.selectionType.trailingStyle }
    var rowTrailing: MPListItemTrailing? { self.output.selectionType.rowTrailing }

    // MARK: - Init

    init(output: MethodSelectionOutput) {
        self.output = output
    }

    // MARK: - Actions

    @discardableResult
    func selectOption(_ optionId: String) -> MethodSelectionOutput.Option? {
        guard let option = self.output.options.first(where: { $0.id == optionId }) else { return nil }

        if self.output.selectionType == .chevron {
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
        return option
    }

    func goBack() {
        // Analytics `off_payment_list_back` is dispatched once a MethodSelection AnalyticsPath exists.
    }
}
