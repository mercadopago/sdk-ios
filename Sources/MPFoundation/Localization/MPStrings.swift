//
//  MPStrings.swift
//  MercadoPagoSDK
//
//  Created by MercadoPago on 10/12/24.
//

import Foundation
import MPCore

/// Type-safe access to localized strings used throughout the SDK.
package enum MPStrings {
    // MARK: - Format Helpers
    package static func format(_ key: String, _ args: CVarArg...) -> String {
        let format = NSLocalizedString(
            key,
            tableName: nil,
            bundle: currentBundle,
            value: key,
            comment: ""
        )
        
        if args.isEmpty {
            return format
        }
        
        return String(format: format, arguments: args)
    }
    
    package static func formatPrice(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        let formattedValue = formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
        return "\(Common.currency) \(formattedValue)"
    }
    
    package static func formatTotal(_ value: Double) -> String {
        "\(Common.total) \(formatPrice(value))"
    }
    
    // MARK: - Internal
    
    private static var currentBundle: Bundle {
        guard let locale = MercadoPagoSDK.shared.configuration?.locale,
              let path = Bundle.bundleMP.path(forResource: locale, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return Bundle.bundleMP
        }
        return bundle
    }
    
    static func localized(_ key: String, _ args: CVarArg...) -> String {
        let format = NSLocalizedString(
            key,
            tableName: nil,
            bundle: currentBundle,
            value: key,
            comment: ""
        )
        
        if args.isEmpty {
            return format
        }
        
        return String(format: format, arguments: args)
    }
}
