//
//  MPMessageStyleConfiguration.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 15/01/26.
//
import MPFoundation
import SwiftUI

package struct MPMessageConfiguration: Sendable {
    let message: String
    let state: MPMessageState
    let dismiss: @MainActor () -> Void

    
    init(message: String, state: MPMessageState, dismiss: @escaping @MainActor () -> Void) {
        self.message = message
        self.state = state
        self.dismiss = dismiss
    }
}

extension View {
    func messageStyle<S: MPMessageStyle>(_ style: S) -> some View {
        environment(\.mpMessageStyle, style)
    }
}

struct MPMessageStyleKey: EnvironmentKey {
    static let defaultValue: any MPMessageStyle = MPDefaultMessageStyle()
}

extension EnvironmentValues {
    var mpMessageStyle: any MPMessageStyle {
        get { self[MPMessageStyleKey.self] }
        set { self[MPMessageStyleKey.self] = newValue }
    }
}

private struct ResolvedMPMessageStyle<Style: MPMessageStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}

package extension MPMessageStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedMPMessageStyle(style: self, configuration: configuration)
    }
}

