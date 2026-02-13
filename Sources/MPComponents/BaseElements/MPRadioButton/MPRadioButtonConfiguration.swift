//
//  MPRadioButtonConfiguration.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 13/02/26.
//

import SwiftUI

package struct MPRadioButtonConfiguration {
    package var isOn: Bool
    
    @MainActor
    init(isOn: Bool) {
        self.isOn = isOn
    }
}

// MARK: - Environment
struct MPRadioButtonStyleKey: EnvironmentKey {
    static let defaultValue: any MPRadioButtonStyle = MPRadioButtonDefaultStyle()
}

extension EnvironmentValues {
    var mpRadioButtonStyle: any MPRadioButtonStyle {
        get { self[MPRadioButtonStyleKey.self] }
        set { self[MPRadioButtonStyleKey.self] = newValue }
    }
}

// MARK: - Style Resolution
package extension MPRadioButtonStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedMPRadioButtonStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedMPRadioButtonStyle<Style: MPRadioButtonStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}
