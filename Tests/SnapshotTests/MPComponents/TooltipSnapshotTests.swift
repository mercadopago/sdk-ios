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
        type: TooltipType = .blue,
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
                        .tooltipTest(type: .dark) {
                            Text("Dark Theme.")
                                .textStyle(.bodySmallRegular(colorType: .inverted))
                        }
                    
                    Text("Second text")
                        .padding()
                        .cornerRadius(8)
                        .tooltipTest(type: .blue) {
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
            as: .image(size: CGSize(width: 400, height: 700))
        )
    }

}
