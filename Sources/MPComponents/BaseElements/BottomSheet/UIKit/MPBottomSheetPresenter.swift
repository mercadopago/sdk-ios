//
//  MPBottomSheetPresenter.swift
//  MPComponents
//

import SwiftUI
import UIKit

struct MPBottomSheetPresenter<Content: View>: UIViewControllerRepresentable {
    // MARK: - Properties

    let isPresented: Binding<Bool>
    let title: String
    let height: CGFloat?
    let content: () -> Content

    // MARK: - UIViewControllerRepresentable

    func makeCoordinator() -> Coordinator {
        Coordinator(self.isPresented, height: self.height)
    }

    func makeUIViewController(context _: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        return vc
    }

    func updateUIViewController(_ backgroundVC: UIViewController, context: Context) {
        context.coordinator.height = self.height
        if self.isPresented.wrappedValue {
            if let existing = context.coordinator.presentedController as? MPAutoUpdateHostingController<MPBottomSheetContent<Content>>,
               !existing.isBeingDismissed {
                existing.rootView = self.makeSheetContent()
                return
            }
            guard context.coordinator.presentedController == nil else { return }
            self.presentSheet(from: backgroundVC, context: context)
        } else {
            if let presented = context.coordinator.presentedController,
               !presented.isBeingDismissed {
                presented.dismiss(animated: true)
            }
            context.coordinator.presentedController = nil
        }
    }

    // MARK: - Helpers

    private func makeSheetContent() -> MPBottomSheetContent<Content> {
        MPBottomSheetContent(
            title: self.title,
            onDismiss: { self.isPresented.wrappedValue = false },
            content: self.content
        )
    }

    private func presentSheet(from backgroundVC: UIViewController, context: Context) {
        let hostingVC = MPAutoUpdateHostingController(rootView: makeSheetContent())
        hostingVC.modalPresentationStyle = .custom
        hostingVC.transitioningDelegate = context.coordinator
        context.coordinator.presentedController = hostingVC

        Task { @MainActor in
            guard
                let presenter = backgroundVC.view.window?.topMostViewController,
                presenter.presentedViewController == nil else {
                return
            }
            presenter.present(hostingVC, animated: true)
        }
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, UIViewControllerTransitioningDelegate, UIAdaptivePresentationControllerDelegate {
        let isPresented: Binding<Bool>
        var height: CGFloat?
        weak var presentedController: UIViewController?

        init(_ isPresented: Binding<Bool>, height: CGFloat?) {
            self.isPresented = isPresented
            self.height = height
        }

        func presentationController(
            forPresented presented: UIViewController,
            presenting: UIViewController?,
            source _: UIViewController
        ) -> UIPresentationController? {
            let ctrl = MPSheetPresentationController(
                presentedViewController: presented,
                presenting: presenting,
                height: height
            )
            ctrl.delegate = self
            ctrl.onDidDismiss = { [weak self] in
                self?.isPresented.wrappedValue = false
                self?.presentedController = nil
            }
            return ctrl
        }

        func animationController(
            forPresented _: UIViewController,
            presenting _: UIViewController,
            source _: UIViewController
        ) -> UIViewControllerAnimatedTransitioning? {
            MPSheetTransitionAnimator(isPresenting: true)
        }

        func animationController(forDismissed _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            MPSheetTransitionAnimator(isPresenting: false)
        }
    }
}

// MARK: - UIWindow helper

private extension UIWindow {
    var topMostViewController: UIViewController? {
        var current = rootViewController
        while let presented = current?.presentedViewController {
            current = presented
        }
        return current
    }
}
