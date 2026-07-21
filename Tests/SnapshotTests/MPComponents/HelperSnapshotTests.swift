//
//  HelperSnapshotTests.swift
//  MercadoPagoSDK
//
//  Created by Codex on 13/01/25.
//

@testable import MPComponents
@testable import MPFoundation
import SnapshotTesting
import SwiftUI
import XCTest

@MainActor
final class HelperSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    func test_helperLoudHierarchyStates() {
        let view = self.createTestView {
            VStack(alignment: .leading, spacing: 16) {
                self.helperRow(text: "Payment approved successfully", tone: .positive)
                self.helperRow(text: "We could not process your payment", tone: .negative)
                self.helperRow(text: "Double check the card data before continuing", tone: .caution)
                self.helperRow(text: "We'll notify you when the payment completes", tone: .informative)
            }
        }

        let hostingController = UIHostingController(rootView: view)

        assertSnapshot(
            of: hostingController,
            as: .image(precision: 0.95, size: CGSize(width: 360, height: 240)),
            named: "helper_loud_hierarchy"
        )
    }

    func test_helperQuietHierarchyStates() {
        let view = self.createTestView {
            VStack(alignment: .leading, spacing: 16) {
                self.helperRow(
                    text: "Only you can see this helper. It is perfect for inline hints with longer text wrapping into multiple lines to ensure layout looks correct in quiet hierarchy.",
                    tone: .informative,
                    hierarchy: .quiet
                )

                self.helperRow(
                    text: "Only you can see this helper. It is perfect for inline hints with longer text wrapping into multiple lines to ensure layout looks correct in quiet hierarchy.",
                    tone: .negative,
                    hierarchy: .quiet
                )

                self.helperRow(
                    text: "Optional helper text without tone or icon, ideal when showing neutral context messages.",
                    tone: .none,
                    hierarchy: .quiet
                )
            }
        }

        let hostingController = UIHostingController(rootView: view)

        assertSnapshot(
            of: hostingController,
            as: .image(precision: 0.95, size: CGSize(width: 360, height: 220)),
            named: "helper_quiet_hierarchy"
        )
    }

    // MARK: - Helper Methods

    private func helperRow(
        text: String,
        tone: HelperTone,
        hierarchy: HelperHierarchy = .loud
    ) -> some View {
        Helper(text, tone)
            .helperStyle(hierarchy)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func createTestView(@ViewBuilder content: @escaping () -> some View) -> some View {
        ThemeProvider(light: MPLightTheme(), dark: MPLightTheme(), style: .lightMode) {
            VStack(alignment: .leading, spacing: 16) {
                content()
                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .loadMPFonts()
        }
    }
}
