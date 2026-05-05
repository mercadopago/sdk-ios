//
//  MPSheetPresentationController.swift
//  MPComponents
//

import UIKit

final class MPSheetPresentationController: UIPresentationController {
    // MARK: - Layout Constants

    enum Layout {
        static let cornerRadius: CGFloat = 20
        static let dimmingAlpha: CGFloat = 0.4
        static let dismissVelocityThreshold: CGFloat = 500
        static let dismissDistanceRatio: CGFloat = 0.4
    }

    // MARK: - Properties

    private let sheetHeight: CGFloat?
    private let dimmingView = UIView()
    var onDidDismiss: (() -> Void)?

    /// Prevents `onDidDismiss` from firing more than once per dismissal cycle.
    /// Set eagerly in user-initiated dismissals (pan, dimmer tap) so
    /// `dismissalTransitionDidEnd` becomes a no-op if those paths already fired it.
    private var dismissNotified = false
    private var panStartY: CGFloat = 0

    // MARK: - Init

    init(presentedViewController: UIViewController, presenting: UIViewController?, height: CGFloat?) {
        self.sheetHeight = height
        super.init(presentedViewController: presentedViewController, presenting: presenting)
    }

    // MARK: - Frame

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView else { return .zero }
        let height = self.sheetHeight ?? containerView.bounds.height * 0.5
        return CGRect(
            x: 0,
            y: containerView.bounds.height - height,
            width: containerView.bounds.width,
            height: height
        )
    }

    // MARK: - Transition Hooks

    override func presentationTransitionWillBegin() {
        guard let containerView else { return }
        self.dimmingView.backgroundColor = UIColor.black.withAlphaComponent(Layout.dimmingAlpha)
        self.dimmingView.alpha = 0
        self.dimmingView.frame = containerView.bounds
        containerView.insertSubview(self.dimmingView, at: 0)
        self.dimmingView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.dimmingTapped))
        )
        presentedViewController.transitionCoordinator?.animate { _ in
            self.dimmingView.alpha = Layout.dimmingAlpha
        }
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        guard completed else { return }
        presentedViewController.view.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        )
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(
            alongsideTransition: { _ in self.dimmingView.alpha = 0 },
            completion: { _ in self.dimmingView.removeFromSuperview() }
        )
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        guard completed, !self.dismissNotified else { return }
        self.dismissNotified = true
        self.onDidDismiss?()
    }

    override func containerViewWillLayoutSubviews() {
        presentedViewController.view.frame = self.frameOfPresentedViewInContainerView
        presentedViewController.view.layer.cornerRadius = Layout.cornerRadius
        presentedViewController.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedViewController.view.layer.masksToBounds = true
    }

    // MARK: - Gesture Handlers

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view, let containerView else { return }
        let translation = gesture.translation(in: containerView)
        let velocity = gesture.velocity(in: containerView)
        let origin = self.frameOfPresentedViewInContainerView.origin.y

        switch gesture.state {
        case .began:
            self.panStartY = view.frame.origin.y

        case .changed:
            let newY = max(origin, panStartY + translation.y)
            view.frame.origin.y = newY
            self.dimmingView.alpha = Layout.dimmingAlpha * (1 - (newY - origin) / view.frame.height)

        case .ended, .cancelled:
            let distanceDragged = view.frame.origin.y - origin
            let shouldDismiss = velocity.y > Layout.dismissVelocityThreshold
                || distanceDragged > view.frame.height * Layout.dismissDistanceRatio

            if shouldDismiss {
                self.dismissNotified = true
                self.onDidDismiss?()
                presentingViewController.dismiss(animated: true)
            } else {
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0,
                    usingSpringWithDamping: 0.8,
                    initialSpringVelocity: 0.5
                ) {
                    view.frame.origin.y = origin
                    self.dimmingView.alpha = Layout.dimmingAlpha
                }
            }

        default:
            break
        }
    }

    @objc private func dimmingTapped() {
        self.dismissNotified = true
        self.onDidDismiss?()
        presentingViewController.dismiss(animated: true)
    }
}
