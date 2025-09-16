//
//  BottomSheetPresenter.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/09/25.
//
import SwiftUI
import UIKit

struct BottomSheetPresenter<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    
    let contentView: () -> Content

    let bottomSheetConfiguration: BottomSheet.Configuration
    
    @State private var router = BottomSheet.Router()

    func makeUIViewController(context: Context) -> UIViewController {
        let presenterVC = UIViewController()
        presenterVC.view.backgroundColor = .clear
        return presenterVC
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard
            uiViewController.view.window != nil || (isPresented && uiViewController.presentedViewController == nil)
        else {
             if isPresented && uiViewController.presentedViewController == nil {
                  DispatchQueue.main.async {
                      self.present(on: uiViewController, context: context)
                  }
             }
            return
        }
        
        if isPresented {
            present(on: uiViewController, context: context)
        } else {
            if let presentedVC = uiViewController.presentedViewController,
               presentedVC.isBeingDismissed == false &&
                (presentedVC is BottomSheet.NavigationController ||
                 presentedVC.presentingViewController === uiViewController
                ) {
                 uiViewController.dismiss(animated: true)
            }
        }
    }
    
    private func present(on uiViewController: UIViewController, context: Context) {
        guard uiViewController.presentedViewController == nil else { return }
        var viewController: UIViewController = .init()

        let rootViewController = uiViewController.setupBottomSheet(
            configuration: self.bottomSheetConfiguration,
            screen: contentView,
            router: self.router,
            viewController: uiViewController
        )
        
        if self.bottomSheetConfiguration.contentPresentationMode == .navigationStack {
            let navigationController = BottomSheet.NavigationController(
                rootViewController: rootViewController,
                configuration: self.bottomSheetConfiguration
            )
            
            router.navigationController = navigationController
            
            viewController = navigationController
        } else {
            viewController = rootViewController
        }

        uiViewController.presentBottomSheet(
            viewController: viewController,
            configuration: self.bottomSheetConfiguration,
            canBeDismissed: { true },
            dismissCompletion: {
                if self.isPresented {
                    self.isPresented = false
                }
            }
        )
    }

}
