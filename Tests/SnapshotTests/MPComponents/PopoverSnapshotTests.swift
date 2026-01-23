//
//  PopoverSnapshotTests.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 09/09/25.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import MPComponents
import MPFoundation

extension View {
    func popoverTest<PopoverContent: View>(
        side: PopoverSide = .bottom,
        type: PopoverType = .white,
        @ViewBuilder content: @escaping () -> PopoverContent
    ) -> some View {
        let config = DefaultPopoverConfig(side: side, type: type)
        let popover = PopoverModifier(config: config, isPresented: .constant(true), content: content)
        return modifier(popover)
    }
}

@MainActor
final class PopoverSnapshotTests: XCTestCase {
    
    // MARK: - Tests: All Sides
    
    func testPopover_SideBottom() {
        let view = makePopoverView(side: .bottom)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.backgroundColor = .darkGray
        
        assertSnapshot(
            of: hostingController,
            as: .image(precision: 0.95, size: CGSize(width: 500, height: 500))
        )
    }
    
    func testPopover_SideTop() {
        let view = makePopoverView(side: .top)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.backgroundColor = .darkGray
        
        assertSnapshot(
            of: hostingController,
            as: .image(precision: 0.95, size: CGSize(width: 500, height: 500))
        )
    }
    
    func testPopover_SideLeft() {
        let view = makePopoverView(side: .left)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.backgroundColor = .darkGray
        
        assertSnapshot(
            of: hostingController,
            as: .image(precision: 0.95, size: CGSize(width: 500, height: 500))
        )
    }
    
    func testPopover_SideRight() {
        let view = makePopoverView(side: .right)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.backgroundColor = .darkGray
        
        assertSnapshot(
            of: hostingController,
            as: .image(precision: 0.95, size: CGSize(width: 500, height: 500))
        )
    }
    
    // MARK: - Helper
    
    private func makePopoverView(side: PopoverSide, alignment: Alignment = .center) -> some View {
        ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
            ZStack(alignment: alignment) {
                Color.clear
                
                Image(systemName: "info.circle")
                    .font(.title)
                    .foregroundColor(.blue)
                    .popoverTest(side: side) {
                        Text("Popover content")
                            .foregroundColor(.black)
                    }
            }
        }
    }
}
