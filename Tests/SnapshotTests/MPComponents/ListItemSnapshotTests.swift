//
//  ListItemSnapshotTests.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 31/07/25.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import MPComponents
@testable import MPFoundation

@MainActor
final class ListItemSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_allStatesComparison() {
        let view = VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Idle")
                    .font(.headline)
                VStack(spacing: 8) {
                    createListItem(title: "Unselected", isSelected: false)
                    createListItem(title: "Selected", isSelected: true)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Disabled")
                    .font(.headline)
                VStack(spacing: 8) {
                    createListItem(title: "Unselected", isSelected: false, disabled: true)
                    createListItem(title: "Selected", isSelected: true, disabled: true)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Error")
                    .font(.headline)
                VStack(spacing: 8) {
                    createListItem(title: "Unselected", isSelected: false, hasError: true)
                    createListItem(title: "Selected", isSelected: true, hasError: true)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Trailing Content")
                    .font(.headline)
                VStack(spacing: 8) {
                    createListItem(
                        title: "With text",
                        trailingContent: .text("Value"),
                        isSelected: false
                    )
                    createListItem(
                        title: "With pill",
                        trailingContent: .pill(text: "Label"),
                        isSelected: false
                    )
                }
            }
        }
        .padding()
        .frame(width: 350)
        
        assertSnapshot(
            of: view,
            as: .image,
            named: "all_states_comparison"
        )
    }

    // MARK: - Helper Methods

    private func createListItem(
        title: String,
        trailingContent: ListItemTrailingContent = .none,
        isSelected: Bool,
        hasError: Bool = false,
        disabled: Bool = false
    ) -> some View {
        ListItem(
            title: title,
            trailingContent: trailingContent,
            isSelected: isSelected
        ) { _ in
            // No action needed for snapshot tests
        }
        .hasError(hasError)
        .disabled(disabled)
        .environment(\.checkoutTheme, MPLightTheme())
        .frame(maxWidth: .infinity, alignment: .leading)
        .loadMPFonts()
    }
}
