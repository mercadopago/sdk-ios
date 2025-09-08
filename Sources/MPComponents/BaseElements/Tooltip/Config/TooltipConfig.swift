//
//  ArrowType.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 08/09/25.
//


import SwiftUI
import MPFoundation

package enum ArrowType: Sendable {
    case `default`
}

package protocol TooltipConfig: Sendable {
    // MARK: - Alignment
    var side: TooltipSide { get set }
    var margin: CGFloat { get set }
    var zIndex: Double { get set }
    
    // MARK: - Sizes
    var width: CGFloat? { get set }
    var height: CGFloat? { get set }

    // MARK: - Tooltip arrow
    var showArrow: Bool { get set }
    var arrowWidth: CGFloat { get set }
    var arrowHeight: CGFloat { get set }
    var arrowType: ArrowType { get set }
    
    // MARK: - Animation settings
    var enableAnimation: Bool { get set }
    var animationOffset: CGFloat { get set }
    var animationTime: Double { get set }
    var animation: Optional<Animation> { get set }
    
    
    var type: TooltipType { get set }
    
    // MARK: - Theme-based methods
    func borderRadius(from theme: MPTheme) -> CGFloat
    func borderWidth(from theme: MPTheme) -> CGFloat
    func borderColor(from theme: MPTheme) -> Color
    func backgroundColor(from theme: MPTheme) -> Color
    func shadowColor(from theme: MPTheme) -> Color
    func shadowRadius(from theme: MPTheme) -> CGFloat
    func shadowOffset(from theme: MPTheme) -> CGPoint
    func contentPadding(from theme: MPTheme) -> EdgeInsets
}
