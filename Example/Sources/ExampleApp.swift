//
//  ExampleApp.swift
//  Example
//
//  Created by Guilherme Prata Costa on Dec 19, 2024.
//  Copyright © 2024 Mercado Pago. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, *)
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

@main
struct ExampleAppWrapper {
    static func main() {
        if #available(iOS 14.0, *) {
            ExampleApp.main()
        } else {
            UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(SceneDelegate.self))
        }
    }
}
