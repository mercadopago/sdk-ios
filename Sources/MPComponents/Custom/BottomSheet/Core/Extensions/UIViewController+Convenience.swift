//
//  UIViewController+Convenience.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/09/25.
//

import UIKit
import SwiftUI

final class DefaultBottomSheetPresentationControllerFactory: @preconcurrency BottomSheetPresentationControllerFactory {
    // MARK: - Nested types

    public typealias DismissalHandlerProvider = () -> BottomSheetModalDismissalHandler

    // MARK: - Public properties

    private let configuration: BottomSheet.Configuration
    private let dismissalHandlerProvider: DismissalHandlerProvider

    // MARK: - Init

    init(
        configuration: BottomSheet.Configuration,
        dismissalHandlerProvider: @escaping DismissalHandlerProvider
    ) {
        self.dismissalHandlerProvider = dismissalHandlerProvider
        self.configuration = configuration
    }

    // MARK: - BottomSheetPresentationControllerFactory

    @MainActor
    func makeBottomSheetPresentationController(
        presentedViewController: UIViewController,
        presentingViewController: UIViewController?
    ) -> BottomSheetPresentationController {
        BottomSheetPresentationController(
            presentedViewController: presentedViewController,
            presentingViewController: presentingViewController,
            dismissalHandler: dismissalHandlerProvider(),
            configuration: configuration
        )
    }
}

final class DefaultBottomSheetModalDismissalHandler: @preconcurrency BottomSheetModalDismissalHandler {
    // MARK: - Private properties

    private weak var presentingViewController: UIViewController?
    private let _canBeDismissed: () -> Bool
    private let dismissCompletion: (() -> Void)?

    private var didInvokeDismissal = false

    // MARK: - Init

    init(
        presentingViewController: UIViewController?,
        canBeDismissed: @escaping (() -> Bool),
        dismissCompletion: (() -> Void)?
    ) {
        self.presentingViewController = presentingViewController
        self._canBeDismissed = canBeDismissed
        self.dismissCompletion = dismissCompletion
    }

    // MARK: - BottomSheetModalDismissalHandler

    var canBeDismissed: Bool {
        _canBeDismissed()
    }

    @MainActor
    func performDismissal(animated: Bool) {
        if let presentedViewController = presentingViewController?.presentedViewController {
            presentedViewController.dismiss(animated: animated, completion: dismissCompletion)
        } else {
            // User dismissed view controller by swipe-gesture, dismiss handler wasn't invoked
            dismissCompletion?()
        }

        didInvokeDismissal = true
    }

    func didEndDismissal() {
        guard !didInvokeDismissal else { return }

        dismissCompletion?()
    }
}

package extension UIViewController {
    private(set) var bottomSheetTransitionDelegate: UIViewControllerTransitioningDelegate? {
        get { objc_getAssociatedObject(self, &Self.bottomSheetTransitionDelegateKey) as? UIViewControllerTransitioningDelegate }
        set { objc_setAssociatedObject(self, &Self.bottomSheetTransitionDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private static var bottomSheetTransitionDelegateKey: UInt8 = 0

    internal func presentBottomSheetController(
        viewController: UIViewController,
        configuration: BottomSheet.Configuration,
        canBeDismissed: @escaping (() -> Bool) = { true },
        dismissCompletion: (() -> Void)? = nil
    ) {
        weak var presentingViewController = self
        weak var currentBottomSheetTransitionDelegate: UIViewControllerTransitioningDelegate?
        let presentationControllerFactory = DefaultBottomSheetPresentationControllerFactory(configuration: configuration) {
            DefaultBottomSheetModalDismissalHandler(presentingViewController: presentingViewController, canBeDismissed: canBeDismissed) {
                if currentBottomSheetTransitionDelegate === presentingViewController?.bottomSheetTransitionDelegate {
                    presentingViewController?.bottomSheetTransitionDelegate = nil
                }
                dismissCompletion?()
            }
        }
        bottomSheetTransitionDelegate = BottomSheetTransitioningDelegate(
            presentationControllerFactory: presentationControllerFactory
        )
        currentBottomSheetTransitionDelegate = bottomSheetTransitionDelegate
        viewController.transitioningDelegate = bottomSheetTransitionDelegate
        viewController.modalPresentationStyle = .custom
        present(viewController, animated: true, completion: nil)
    }

    func presentBottomSheet(
        viewController: UIViewController,
        configuration: BottomSheet.Configuration,
        canBeDismissed: @escaping (() -> Bool) = { true },
        dismissCompletion: (() -> Void)? = nil
    ) {
        presentBottomSheetController(
            viewController: viewController,
            configuration: configuration,
            canBeDismissed: canBeDismissed,
            dismissCompletion: dismissCompletion
        )
    }
    
    
    func setupBottomSheet<Content: View>(
        configuration: BottomSheet.Configuration,
        screen: () -> Content,
        router: BottomSheet.Router,
        viewController: UIViewController
    ) -> UIViewController {
        let content = screen().environmentObject(router)

        let hostingController = BottomSheet.NavigationHost(
            rootView: content,
            router: router
        )

        let initialWidth = viewController.view.bounds.width > 0
            ? viewController.view.bounds.width
            : UIScreen.main.bounds.width
        
        hostingController.preferredContentSize = CGSize(
            width: initialWidth,
            height: 400
        )

        hostingController.onHeightDidChange = { [weak hostingController] heightCalculatedByDHC in
            guard let hc = hostingController else { return }
            if abs(hc.preferredContentSize.height - heightCalculatedByDHC) > 0.5 && heightCalculatedByDHC > 0 {
                hc.preferredContentSize = CGSize(
                    width: hc.view.bounds.width > 0 ? hc.view.bounds.width : initialWidth,
                    height: heightCalculatedByDHC
                )
            }
        }

        return hostingController
    }
}
