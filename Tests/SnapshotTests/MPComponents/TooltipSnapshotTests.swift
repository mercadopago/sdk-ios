//
//  TooltipSnapshotTests.swift
//  MercadoPagoSDK
//

@testable import MPComponents
import MPFoundation
import SnapshotTesting
import SwiftUI
import XCTest

@MainActor
final class TooltipSnapshotTests: XCTestCase {
    // MARK: - Tests: All Sides

    func testTooltip_SideTop() {
        assertSnapshot(
            of: self.makeHostingController(side: .top),
            as: .image(precision: 0.95, size: self.snapshotSize)
        )
    }

    func testTooltip_SideBottom() {
        assertSnapshot(
            of: self.makeHostingController(side: .bottom),
            as: .image(precision: 0.95, size: self.snapshotSize)
        )
    }

    func testTooltip_SideLeft() {
        assertSnapshot(
            of: self.makeHostingController(side: .left),
            as: .image(precision: 0.95, size: self.snapshotSize)
        )
    }

    func testTooltip_SideRight() {
        assertSnapshot(
            of: self.makeHostingController(side: .right),
            as: .image(precision: 0.95, size: self.snapshotSize)
        )
    }

    // MARK: - Helpers

    private let snapshotSize = CGSize(width: 500, height: 500)

    private func triggerFrame(for side: MPTooltipSide) -> CGRect {
        switch side {
        case .top: return CGRect(x: 225, y: 300, width: 50, height: 30)
        case .bottom: return CGRect(x: 225, y: 200, width: 50, height: 30)
        case .left: return CGRect(x: 300, y: 235, width: 50, height: 30)
        case .right: return CGRect(x: 150, y: 235, width: 50, height: 30)
        }
    }

    private func makeHostingController(side: MPTooltipSide) -> UIHostingController<some View> {
        let size = self.snapshotSize
        let trigger = self.triggerFrame(for: side)
        let view = ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
            ZStack {
                Color(UIColor.systemGray6)

                Rectangle()
                    .fill(Color.blue.opacity(0.4))
                    .frame(width: trigger.width, height: trigger.height)
                    .position(x: trigger.midX, y: trigger.midY)

                MPTooltipFloatingContent(
                    triggerFrame: trigger,
                    config: MPDefaultTooltipConfig(side: side),
                    theme: MPLightTheme(),
                    content: AnyView(Text("Tooltip content")),
                    onDismiss: {}
                )
            }
            .frame(width: size.width, height: size.height)
        }

        let hostingController = UIHostingController(rootView: view)
        hostingController.view.backgroundColor = .clear

        let window = UIWindow(frame: CGRect(origin: .zero, size: snapshotSize))
        window.rootViewController = hostingController
        window.makeKeyAndVisible()

        hostingController.view.frame = CGRect(origin: .zero, size: self.snapshotSize)
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
        hostingController.view.layoutIfNeeded()
        return hostingController
    }
}
