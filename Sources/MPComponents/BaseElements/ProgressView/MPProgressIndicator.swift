//
//  MPProgressView.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 25/02/26.
//
import SwiftUI

package struct MPProgressIndicator: View {

    @Environment(\.mpProgressIndicatorSize) private var size: MPProgressIndicatorSize
    @Environment(\.mpProgressViewStyle) private var style: any MPProgressIndicatorStyle

    package init() {}

    package var body: some View {
        let configuration = MPProgressIndicatorStyleConfiguration(size: size)
        return AnyView(style.resolve(configuration: configuration))
    }
}
