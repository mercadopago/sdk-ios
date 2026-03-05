//
//  MainListView.swift
//  Example
//
//  Created by Guilherme Prata Costa on 16/01/25.
//

import SwiftUI
import UIKit

struct MainListView: View {
    @State private var showingCardForm = false

    @State private var showingCardFormSwiftUI = false

    @State private var showDebug = false

    var body: some View {
        NavigationView {
            List {
                Section("Payment Forms") {
                    Button("Card Form (UIKit)") {
                        self.showingCardForm = true
                    }

                    Button("Card Form (SwiftUI)") {
                        self.showingCardFormSwiftUI = true
                    }
                }

                Section("Settings") {
                    Button("Debugging") {
                        self.showDebug = true
                    }
                    NavigationLink("About", destination: Text("Under construction"))
                }
            }
            .navigationTitle("Demo App")
        }
        .fullScreenCover(isPresented: self.$showingCardForm) {
            CardFormViewControllerRepresentable()
        }
        .sheet(isPresented: self.$showingCardFormSwiftUI) {
            CardFormView()
        }
        .sheet(isPresented: self.$showDebug) {
            DebugView()
        }
    }
}

struct CardFormViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let cardFormVC = CardFormViewController()
        let navigationController = UINavigationController(rootViewController: cardFormVC)

        cardFormVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: context.coordinator,
            action: #selector(Coordinator.dismiss)
        )
        cardFormVC.title = "Card Form"
        return navigationController
    }

    func updateUIViewController(_: UINavigationController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: CardFormViewControllerRepresentable

        init(_ parent: CardFormViewControllerRepresentable) {
            self.parent = parent
        }

        @objc func dismiss() {
            UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
        }
    }
}

/// Preview
struct MainListView_Previews: PreviewProvider {
    static var previews: some View {
        MainListView()
    }
}
