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

    // MARK: - Events

    var onOptionSelected: ((MethodSelectionOutput.Option) -> Void)?
    var onBack: (() -> Void)?

    // MARK: - Init

    init(output: MethodSelectionOutput) {
        self.output = output
    }

    // MARK: - Actions

    func selectOption(_ optionId: String) {
        guard let option = self.output.options.first(where: { $0.id == optionId }) else { return }

        if self.output.selectionType == .chevron {
            self.onOptionSelected?(option)
            return
        }

        self.selectedOptionId = option.id
        self.isCtaEnabled = true
    }

    func confirmSelection() {
        guard let selectedId = self.selectedOptionId,
              let option = self.output.options.first(where: { $0.id == selectedId }) else { return }

        self.selectedOptionId = nil
        self.isCtaEnabled = false
        self.onOptionSelected?(option)
    }

    func goBack() {
        // Analytics `off_payment_list_back` is dispatched once a MethodSelection AnalyticsPath exists.
        self.onBack?()
    }
}
