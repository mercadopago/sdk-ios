//
//  DefaultTooltipConfig.swift
//  MPComponents
//

package struct MPDefaultTooltipConfig: MPTooltipConfig {
    package var side: MPTooltipSide

    package init(side: MPTooltipSide = .top) {
        self.side = side
    }
}
