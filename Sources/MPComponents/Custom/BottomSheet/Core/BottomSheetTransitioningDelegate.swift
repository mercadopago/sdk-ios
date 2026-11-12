//
//  BottomSheetTransitioningDelegate.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/09/25.
//

import UIKit

protocol BottomSheetPresentationControllerFactory {
    func makeBottomSheetPresentationController(
        presentedViewController: UIViewController,
        presentingViewController: UIViewController?
    ) -> BottomSheetPresentationController
}

final class BottomSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    // MARK: - Private properties

    private weak var presentationController: BottomSheetPresentationController?
    private let presentationControllerFactory: BottomSheetPresentationControllerFactory

    // MARK: - Init

    init(presentationControllerFactory: BottomSheetPresentationControllerFactory) {
        self.presentationControllerFactory = presentationControllerFactory
    }

    // MARK: - UIViewControllerTransitioningDelegate

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        _presentationController(forPresented: presented, presenting: presenting, source: source)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentationController
    }

    func interactionControllerForPresentation(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        presentationController?.interactiveTransition
    }

    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        presentationController?.interactiveTransition
    }

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        _presentationController(forPresented: presented, presenting: presenting, source: source)
    }

    // MARK: - Private methods

    private func _presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> BottomSheetPresentationController {
        if let presentationController = presentationController {
            return presentationController
        }

        let controller = presentationControllerFactory.makeBottomSheetPresentationController(
            presentedViewController: presented,
            presentingViewController: presenting
        )

        presentationController = controller

        return controller
    }
}
