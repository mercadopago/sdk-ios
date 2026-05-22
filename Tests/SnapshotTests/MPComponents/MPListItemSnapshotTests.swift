//
//  MPListItemSnapshotTests.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 31/07/25.
//

@testable import MPComponents
@testable import MPFoundation
import SnapshotTesting
import SwiftUI
import XCTest

@MainActor
final class MPListItemSnapshotTests: XCTestCase {
    func test_allStatesComparison() {
        FontName.registerCustomFonts()

        let view = self.createTestView {
            VStack(spacing: 12) {
                self.listItem(
                    title: "Default",
                    description: "With description",
                    rightText: "$ 1,000.00",
                    rightTextColor: .primary,
                    isSelected: .constant(true),
                    leftImageSystemName: "creditcard"
                )

                self.listItem(
                    title: "Selected",
                    description: "With description",
                    rightText: "$ 1,000.00",
                    rightTextColor: .primary,
                    isSelected: .constant(false)
                )

                self.listItem(
                    title: "Without chevron",
                    description: "Leading image and text",
                    rightText: "$ 1,000.00",
                    rightTextColor: .primary,
                    isSelected: .constant(false),
                    leftImageSystemName: "checkmark.seal"
                )

                self.listItem(
                    header: "With Header",
                    rightText: "$ 1,000.00",
                    rightTextColor: .primary,
                    isSelected: .constant(false),
                    leftImageSystemName: "checkmark.seal"
                )

                self.listItem(
                    title: "Title",
                    header: "With Header",
                    rightText: "$ 1,000.00",
                    rightTextColor: .primary,
                    isSelected: .constant(false),
                    leftImageSystemName: "checkmark.seal"
                )

                self.listItem(
                    title: "Without chevron"
                )
            }
            .listItemStyle(MPListRowRadioStyle())
            .listItemTrailingStyle(.textIcon(Image(systemName: "chevron.right")))
        }

        let hostingController = UIHostingController(rootView: view)

        assertSnapshot(
            of: hostingController,
            as: .image(precision: 0.95, size: CGSize(width: 360, height: 480)),
            named: "all_states_comparison"
        )
    }

    // MARK: - Pick Style

    func test_pickStyle_allStatesComparison() {
        FontName.registerCustomFonts()

        let view = self.createTestView {
            VStack(spacing: 12) {
                self.listItem(
                    title: "Default",
                    description: "With description",
                    rightText: "$ 1,000.00",
                    rightTextColor: .primary,
                    isSelected: .constant(true),
                    leftImageSystemName: "creditcard"
                )

                self.listItem(
                    title: "Selected",
                    description: "With description",
                    rightText: "$ 1,000.00",
                    rightTextColor: .primary,
                    isSelected: .constant(false)
                )

                self.listItem(
                    title: "Title only",
                    rightText: "$ 1,000.00",
                    rightTextColor: .primary,
                    isSelected: .constant(true)
                )

                self.listItem(
                    title: "Without trailing"
                )
            }
            .listItemStyle(MPListRowPickStyle())
            .listItemTrailingStyle(.textIcon(Image(systemName: "chevron.right")))
        }

        let hostingController = UIHostingController(rootView: view)

        assertSnapshot(
            of: hostingController,
            as: .image(precision: 0.95, size: CGSize(width: 360, height: 400)),
            named: "pick_all_states_comparison"
        )
    }

    // MARK: - Helper Methods

    private func listItem(
        title: String? = nil,
        description: String? = nil,
        header: String? = nil,
        rightText: String = "",
        rightTextColor: TextStyleColorType? = nil,
        isSelected: Binding<Bool>? = nil,
        leftImageSystemName: String? = nil,
        leading: MPListItemLeading? = nil
    ) -> some View {
        let resolvedLeading: MPListItemLeading? = leading ?? leftImageSystemName.map { .image(Image(systemName: $0)) }
        return MPListItem(
            isSelected: isSelected ?? .constant(false),
            leading: resolvedLeading,
            contentInfo: .init(title: title, header: header, description: description),
            trailing: .init(text: rightText, color: rightTextColor)
        )
    }

    private func createTestView(@ViewBuilder content: @escaping () -> some View) -> some View {
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
