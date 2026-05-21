//
//  MPIconThumbnailFlagSnapshotTests.swift
//  MercadoPagoSDK
//

@testable import MPComponents
@testable import MPFoundation
import SnapshotTesting
import SwiftUI
import XCTest

@MainActor
final class MPIconThumbnailFlagSnapshotTests: XCTestCase {
    func test_thumbnailFlag_allSources() {
        FontName.registerCustomFonts()

        let view = self.createTestView {
            HStack(spacing: 12) {
                MPIcon(source: .system(name: "creditcard"))
                    .mpIconStyle(.thumbnailFlag)

                MPIcon(source: .system(name: "plus"))
                    .mpIconStyle(.thumbnailFlag)

                MPIcon(source: .system(name: "doc.text"))
                    .mpIconStyle(.thumbnailFlag)
            }
            .padding(16)
        }

        let hostingController = UIHostingController(rootView: view)

        assertSnapshot(
            of: hostingController,
            as: .image(precision: 0.95, size: CGSize(width: 220, height: 80)),
            named: "thumbnailFlag_allSources"
        )
    }

    func test_thumbnailFlag_inListItem() {
        FontName.registerCustomFonts()

        let view = self.createTestView {
            VStack(spacing: 8) {
                MPListItem(
                    leading: .thumbnail(nil),
                    contentInfo: .init(title: "Pix")
                )

                MPListItem(
                    leading: .image(Image(systemName: "creditcard")),
                    contentInfo: .init(title: "Visa •••• 1234", description: "Crédito")
                )
            }
            .listItemStyle(.pick)
            .listItemTrailingStyle(.textIcon(Image(systemName: "chevron.right")))
        }

        let hostingController = UIHostingController(rootView: view)

        assertSnapshot(
            of: hostingController,
            as: .image(precision: 0.95, size: CGSize(width: 360, height: 140)),
            named: "thumbnailFlag_inListItem"
        )
    }

    private func createTestView(@ViewBuilder content: @escaping () -> some View) -> some View {
        ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .loadMPFonts()
        }
    }
}
