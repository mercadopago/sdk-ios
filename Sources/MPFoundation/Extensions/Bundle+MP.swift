//
//  BundleFinder.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 22/08/25.
//
import Foundation
import SwiftUI

private class BundleFinder {}

package extension Bundle {
    @MainActor
    static var bundleMP: Bundle = {
        return Bundle.module
    }()
}



