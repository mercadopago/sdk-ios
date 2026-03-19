//
//  ExampleApp.swift
//  Example
//
//  Created by Guilherme Prata Costa on Dec 19, 2024.
//  Copyright © 2024 Mercado Pago. All rights reserved.
//

import CoreMethods
import SwiftUI

@available(iOS 14.0, *)
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            MainListView()
        }
    }
}

@main
struct ExampleAppWrapper {
    static func main() {
        if #available(iOS 14.0, *) {
            let configuration = MercadoPagoSDK.Configuration(publicKey: "APP_USR-1176f158-b851-4e96-a5db-546f02e41e79", country: .ARG)
            MercadoPagoSDK.shared.initialize(configuration)

            ExampleApp.main()
        } else {
            UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(SceneDelegate.self))
        }
    }
}
