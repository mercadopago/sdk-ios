//
//  MPProgressViewSnapshotTests.swift
//  MercadoPagoSDK
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import MPComponents
@testable import MPFoundation

@MainActor
final class MPProgressViewSnapshotTests: XCTestCase {

    func test_animationMoments() async throws {
        let view = createTestView {
            MPProgressView()
        }

        let hostingController = UIHostingController(rootView: view)
        let window = makeWindow(for: hostingController)

        try await Task.sleep(nanoseconds: 50_000_000) // 0.05s

        assertSnapshot(
            of: hostingController,
            as: .image(precision: 0.85, size: CGSize(width: 120, height: 120)),
            named: "moment_1_start"
        )

        try await Task.sleep(nanoseconds: 300_000_000) // +0.3s
        assertSnapshot(
            of: hostingController,
            as: .image(precision: 0.85, size: CGSize(width: 120, height: 120)),
            named: "moment_2_growing"
        )

        try await Task.sleep(nanoseconds: 300_000_000) // +0.3s
        assertSnapshot(
            of: hostingController,
            as: .image(precision: 0.85, size: CGSize(width: 120, height: 120)),
            named: "moment_3_peak"
        )

        window.isHidden = true
    }

    // MARK: - Helpers

    private func createTestView<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
            content()
                .padding(24)
                .background(Color.white)
        }
    }

    @discardableResult
    private func makeWindow(for viewController: UIViewController) -> UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        return window
    }
}
