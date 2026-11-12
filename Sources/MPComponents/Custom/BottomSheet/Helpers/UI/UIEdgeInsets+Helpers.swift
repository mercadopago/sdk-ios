//
//  UIEdgeInsets+Helpers.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/09/25.
//
import UIKit

extension UIEdgeInsets {
    @inlinable
    var horizontalInsets: CGFloat {
        left + right
    }

    @inlinable
    var verticalInsets: CGFloat {
        top + bottom
    }
}
