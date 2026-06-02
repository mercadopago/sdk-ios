//
//  MPIcon.swift
//  MercadoPagoSDK
//
//  Created by Codex on 05/02/25.
//

import SwiftUI

package struct MPIcon: View {
    private let source: MPIconSource
    private let size: MPIconSize
    private let color: MPIconColor
    private let weight: MPIconWeight

    private let isDecorative: Bool
    
    @Environment(\.mpIconStyle) private var style: any MPIconStyle
    
    package init(
        source: MPIconSource,
        size: MPIconSize = .medium,
        color: MPIconColor = .primary,
        weight: MPIconWeight = .regular,
        isDecorative: Bool = false
    ) {
        self.source = source
        self.size = size
        self.color = color
        self.weight = weight
        self.isDecorative = isDecorative
    }
    
    package init(
        systemName: String,
        size: MPIconSize = .medium,
        color: MPIconColor = .primary,
        weight: MPIconWeight = .regular,
        isDecorative: Bool = false
    ) {
        self.init(
            source: .system(name: systemName),
            size: size,
            color: color,
            weight: weight,
            isDecorative: isDecorative
        )
    }
    
    package init(
        assetName: String,
        size: MPIconSize = .medium,
        color: MPIconColor = .primary,
        weight: MPIconWeight = .regular,
        isDecorative: Bool = false
    ) {
        self.init(
            source: .asset(name: assetName),
            size: size,
            color: color,
            weight: weight,
            isDecorative: isDecorative
        )
    }
    
    package var body: some View {
        let configuration = MPIconStyleConfiguration(
            source: source,
            size: size,
            color: color,
            weight: weight
        )
        
        return AnyView(
            style.resolve(configuration: configuration)
        )
        
    }
}


