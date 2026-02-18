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
final class MPListItemSnapshotTests: XCTestCase {
    
    func test_allStatesComparison() {
        FontName.registerCustomFonts()

        let view = createTestView {
            VStack(spacing: 12) {
                self.listItem(
                    title: "Default",
                    description: "With description",
                    rightText: "$ 1,000.00",
                    rightTextColor: .primary,
                    trailingType: .icon(Image(systemName: "chevron.right")),
                    type: .radioButton(selected: true),
                    leftImageSystemName: "creditcard"
                )
                
                self.listItem(
                    title: "Selected",
                    description: "With description",
                    rightText: "$ 1,000.00",
                    rightTextColor: .primary,
                    trailingType: .icon(Image(systemName: "chevron.right")),
                    type: .radioButton(selected: false)
                )
                
                self.listItem(
                    title: "Without chevron",
                    description: "Leading image and text",
                    rightText: "$ 1,000.00",
                    rightTextColor: .primary,
                    type: .radioButton(selected: false),
                    leftImageSystemName: "checkmark.seal"
                )

                self.listItem(
                    header: "With Header",
                    rightText: "$ 1,000.00",
                    rightTextColor: .primary,
                    type: .radioButton(selected: false),
                    leftImageSystemName: "checkmark.seal"
                )
                
                self.listItem(
                    title: "Title",
                    header: "With Header",
                    rightText: "$ 1,000.00",
                    rightTextColor: .primary,
                    type: .radioButton(selected: false),
                    leftImageSystemName: "checkmark.seal"
                )
                
                
                self.listItem(
                    title: "Without chevron",
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
        title: String? = nil,
        description: String? = nil,
        header: String? = nil,
        rightText: String = "",
        rightTextColor: TextStyleColorType? = nil,
        trailingType: MPListItemTrailing.MPTrailingType? = nil,
        type: MPListItemType? = nil,
        leftImageSystemName: String? = nil
    ) -> some View {
        MPListItem(
            type: type,
            leftImage: leftImageSystemName.map(Image.init(systemName:)),
            contentInfo: .init(title: title, header: header, description: description),
            trailing: .init(text: rightText, color: rightTextColor, type: trailingType)
        )
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
