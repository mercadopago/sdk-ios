//
//  ScreenScale+Helpers.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/09/25.
//
import UIKit

@MainActor
var pixelSize: CGFloat {
    let scale = UIScreen.mainScreenScale
    return 1.0 / scale
}

@MainActor
extension CGFloat {
    var pixelCeiled: CGFloat {
        let scale = UIScreen.mainScreenScale
        return Darwin.ceil(self * scale) / scale
    }
}

@MainActor
extension CGPoint {
    var pixelCeiled: CGPoint {
        CGPoint(x: x.pixelCeiled, y: y.pixelCeiled)
    }
}

@MainActor
extension CGSize {
    var pixelCeiled: CGSize {
        CGSize(width: width.pixelCeiled, height: height.pixelCeiled)
    }
}

extension UIScreen {
    static let mainScreenScale = UIScreen.main.scale
    static let mainScreenPixelSize = CGFloat(1.0) / mainScreenScale
}
