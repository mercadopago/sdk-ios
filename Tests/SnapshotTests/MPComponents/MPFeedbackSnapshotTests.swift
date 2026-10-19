//
//  MPFeedbackSnapshotTests.swift
//  MercadoPagoSDK
//

@testable import MPComponents
@testable import MPFoundation
import SnapshotTesting
import SwiftUI
import XCTest

@MainActor
final class MPFeedbackSnapshotTests: XCTestCase {
    func test_feedback_defaultStyle() {
        FontName.registerCustomFonts()

        let view = self.createTestView {
            MPFeedback(
                title: "Pagamento aprovado",
                iconSource: .system(name: "checkmark.circle.fill")
            )
        }

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(precision: 0.95, size: CGSize(width: 390, height: 190)),
            named: "default"
        )
    }

    func test_feedback_accessibilityDynamicType() {
        FontName.registerCustomFonts()

        let view = self.createTestView {
            MPFeedback(
                title: "Pagamento aprovado",
                iconSource: .system(name: "checkmark.circle.fill")
            )
            .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
        }

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(precision: 0.95, size: CGSize(width: 390, height: 520)),
            named: "accessibility_dynamic_type"
        )
    }

    private func createTestView(@ViewBuilder content: @escaping () -> some View) -> some View {
        ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
            content()
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color.white)
                .loadMPFonts()
        }
    }
}
