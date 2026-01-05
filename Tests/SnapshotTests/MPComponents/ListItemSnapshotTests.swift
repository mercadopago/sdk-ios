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
    
    func test_allStatesComparison() {
        let view = createTestView {
            VStack(spacing: 12) {
                self.listItem(
                    title: "Default",
                    description: "With description",
                    rightText: "$ 1,000.00",
                    hasChevron: true,
                    leftImageSystemName: "creditcard"
                )
                
                self.listItem(
                    title: "Selected",
                    description: "With description",
                    rightText: "$ 1,000.00",
                    hasChevron: true,
                    isSelected: true,
                    leftImageSystemName: "creditcard"
                )
                
                self.listItem(
                    title: "Disabled",
                    description: "With description",
                    rightText: "$ 1,000.00",
                    hasChevron: true,
                    isDisabled: true,
                    leftImageSystemName: "creditcard"
                )
                
                self.listItem(
                    title: "Without chevron",
                    description: "Leading image and text",
                    rightText: "Action",
                    hasChevron: false,
                    leftImageSystemName: "checkmark.seal"
                )
                
                self.listItem(
                    title: "Minimal content",
                    hasChevron: true
                )
            }
        }
        
        let hostingController = UIHostingController(rootView: view)
        
        assertSnapshot(
            of: hostingController,
            as: .image(precision: 0.95, size: CGSize(width: 360, height: 480)),
            named: "all_states_comparison"
        )
    }
    
    // MARK: - Helper Methods
    
    private func listItem(
        title: String,
        description: String = "",
        rightText: String = "",
        hasChevron: Bool = false,
        isSelected: Bool = false,
        isDisabled: Bool = false,
        leftImageSystemName: String? = nil
    ) -> some View {
        ListItem(
            leftImage: leftImageSystemName.map(Image.init(systemName:)),
            title: title,
            description: description,
            rightText: rightText,
            hasChevron: hasChevron,
            isSelected: isSelected
        )
        .disabled(isDisabled)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func createTestView<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
            VStack(alignment: .leading, spacing: 12) {
                content()
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .loadMPFonts()
        }
    }
}
