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
    func tooltipTest<TooltipContent: View>(
        type: TooltipType = .white,
        @ViewBuilder content: @escaping () -> TooltipContent
    ) -> some View {
        var config: TooltipConfig = DefaultTooltipConfig()
        config.type = type
        
        let tooltip = TooltipModifier(isTooltipEnabled: true, config: config, content: content)

        return modifier(tooltip)
    }
}

@MainActor
final class TooltipSnapshotTests: XCTestCase {
    
    struct TooltipView: View {
        public init() {}
        
        public var body: some View {
            ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
                VStack(spacing: 90) {
                    Image(systemName: "info.circle")
                        .font(.title)
                        .foregroundColor(.blue)
                        .tooltipTest(type: .white) {
                            Text("Dark Theme.")
                                .textStyle(.bodyMedium(colorType: .inverted))
                        }
                    
                    Text("Second text")
                        .padding()
                        .cornerRadius(8)
                        .tooltipTest(type: .white) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Blue Theme")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text("This tooltip uses the dark theme for better contrast.")
                                    .font(.body)
                                    .foregroundColor(.white)
                            }
                        }
                    
                }
            }
        }
    }

    func testTooltipView() {
        let view = TooltipView()

        let hostingController = UIHostingController(rootView: view)
        
        assertSnapshot(
            of: hostingController,
            as: .image(precision: 0.95, size: CGSize(width: 400, height: 700))
        )
    }

}
