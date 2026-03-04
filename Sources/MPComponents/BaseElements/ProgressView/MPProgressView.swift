//
//  MPProgressView.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 25/02/26.
//
import SwiftUI

package struct MPProgressView: View {

    @Environment(\.mpProgressViewSize) private var size: MPProgressViewSize
    @Environment(\.mpProgressViewStyle) private var style: any MPProgressViewStyle

    package init() {}

    package var body: some View {
        let configuration = MPProgressViewStyleConfiguration(size: size)
        return AnyView(style.resolve(configuration: configuration))
    }
}
