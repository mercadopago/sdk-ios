//
//  UIColor+DynamicColor.swift
//  Example
//
//  Created by Guilherme Prata Costa on 22/05/25.
//
import UIKit

extension UIColor {
    static let dynamicColor: UIColor = {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return .white
            default:
                return .black
            }
        }
    }()
}
