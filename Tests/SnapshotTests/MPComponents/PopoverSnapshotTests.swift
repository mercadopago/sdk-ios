//
//  PopoverSnapshotTests.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 09/09/25.
//

@testable import MPComponents
import MPFoundation
import SnapshotTesting
import SwiftUI
import XCTest

@MainActor
final class PopoverSnapshotTests: XCTestCase {
    // MARK: - Tests: All Sides

    func testPopover_SideBottom() {
        assertSnapshot(
            of: self.makeHostingController(side: .bottom),
            as: .image(precision: 0.95, size: self.snapshotSize)
        )
    }

    func testPopover_SideTop() {
        assertSnapshot(
            of: self.makeHostingController(side: .top),
            as: .image(precision: 0.95, size: self.snapshotSize)
        )
    }

    func testPopover_SideLeft() {
        assertSnapshot(
            of: self.makeHostingController(side: .left),
            as: .image(precision: 0.95, size: self.snapshotSize)
        )
    }

    func testPopover_SideRight() {
        assertSnapshot(
            of: self.makeHostingController(side: .right),
            as: .image(precision: 0.95, size: self.snapshotSize)
        )
    }

    // MARK: - Helpers

    /// Fixed snapshot canvas size.
    private let snapshotSize = CGSize(width: 500, height: 500)

    /// Returns a trigger frame positioned so the bubble has room to appear on the correct side.
    /// calculateAdjustedPosition() uses UIScreen.main.bounds for clamping, so we place the trigger
    /// away from the edge opposite to where the bubble will appear.
    private func triggerFrame(for side: PopoverSide) -> CGRect {
        switch side {
        case .top: return CGRect(x: 225, y: 300, width: 50, height: 30) // trigger low → bubble above
        case .bottom: return CGRect(x: 225, y: 200, width: 50, height: 30) // trigger high → bubble below
        case .left: return CGRect(x: 300, y: 235, width: 50, height: 30) // trigger right → bubble left
        case .right: return CGRect(x: 100, y: 235, width: 50, height: 30) // trigger left → bubble right
        default: return CGRect(x: 225, y: 235, width: 50, height: 30)
        }
    }

    /// Renders `MPPopoverFloatingContent` directly — bypasses UIViewControllerRepresentable
    /// and the deferred `present()` call so the bubble is visible in synchronous snapshots.
    private func makeHostingController(side: PopoverSide) -> UIHostingController<some View> {
        let size = self.snapshotSize
        let trigger = self.triggerFrame(for: side)
        let view = ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
            ZStack {
                Color(UIColor.darkGray)

                // Anchor indicator so reviewers can see where the trigger sits
                Rectangle()
                    .fill(Color.blue.opacity(0.4))
                    .frame(width: trigger.width, height: trigger.height)
                    .position(x: trigger.midX, y: trigger.midY)

                MPPopoverFloatingContent(
                    triggerFrame: trigger,
                    config: DefaultPopoverConfig(side: side, type: .white),
                    theme: MPLightTheme(),
                    content: AnyView(
                        Text("Popover content")
                            .foregroundColor(.black)
                    ),
                    onDismiss: {}
                )
            }
            .frame(width: size.width, height: size.height)
        }

        let hostingController = UIHostingController(rootView: view)
        hostingController.view.backgroundColor = .clear
        // onPreferenceChange updates @State via DispatchQueue.main.async (required to avoid
        // "Modifying state during view update" in Xcode Canvas previews).
        // Three cycles: layout → async fires → layout with updated measuredSize →
        // SwiftUI schedules re-render → async fires again → final layout.
        hostingController.view.frame = CGRect(origin: .zero, size: self.snapshotSize)
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
        hostingController.view.layoutIfNeeded()
        return hostingController
    }
}
