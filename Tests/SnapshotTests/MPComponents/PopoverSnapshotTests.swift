//
//  ButtonSnapshotTests 2.swift
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
        type: PopoverType = .white,
        @ViewBuilder content: @escaping () -> PopoverContent
    ) -> some View {
        var config: PopoverConfig = DefaultPopoverConfig()
        config.type = type
        
        let popover = PopoverModifier(isPopoverEnabled: true, config: config, content: content)

        return modifier(popover)
    }
}

@MainActor
final class PopoverSnapshotTests: XCTestCase {
    
    struct PopoverView: View {
        public init() {}
        
        public var body: some View {
            ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
                VStack(spacing: 90) {
                    Image(systemName: "info.circle")
                        .font(.title)
                        .foregroundColor(.blue)
                        .popoverTest(type: .white) {
                            Text("Dark Theme.")
                                .textStyle(.bodyMedium(colorType: .accent))
                        }
                    
                    Text("Second text")
                        .padding()
                        .cornerRadius(8)
                        .popoverTest(type: .white) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Blue Theme")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                
                                Text("This popover uses the dark theme for better contrast.")
                                    .font(.body)
                                    .foregroundColor(.black)
                            }
                        }
                }
            }
        }
    }

    func testPopoverView() {
        let view = PopoverView()

        let hostingController = UIHostingController(rootView: view)
        
        hostingController.view.backgroundColor = .darkGray
        
        assertSnapshot(
            of: hostingController,
            as: .image(precision: 0.95, size: CGSize(width: 400, height: 700))
        )
    }

}
