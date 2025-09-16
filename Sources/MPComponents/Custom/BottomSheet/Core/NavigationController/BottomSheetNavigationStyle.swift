//
//  BottomSheetNavigationStyle.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/09/25.
//
import UIKit

final class BottomSheetNavigationAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    // MARK: - Private

    private let operation: UINavigationController.Operation
    private let configuration: BottomSheet.Configuration

    // MARK: - Init

    init(
        operation: UINavigationController.Operation,
        configuration: BottomSheet.Configuration
    ) {
        self.operation = operation
        self.configuration = configuration
    }

    // MARK: - UIViewControllerAnimatedTransitioning

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.25
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        guard
            let sourceViewController = transitionContext.viewController(forKey: .from),
            let destinationViewController = transitionContext.viewController(forKey: .to),
            let destinationView = destinationViewController.view,
            let sourceView = sourceViewController.view,
            let containerViewWindow = containerView.window
        else {
            return
        }

        let isPushing = operation == .push

        let containerBounds = containerView.bounds

        let topView = isPushing ? destinationView : sourceView
        let bottomView = isPushing ? sourceView : destinationView

        let topViewFrame = { bounds, isTopViewVisible -> CGRect in
            isTopViewVisible
                ? bounds
                : bounds.offsetBy(dx: bounds.width, dy: 0)
        }

        let bottomViewFrame = { bounds, isTopViewVisible -> CGRect in
            isTopViewVisible
                ? bounds.offsetBy(dx: -bounds.width, dy: 0)
                : bounds
        }

        let originalTopViewAutoresizingMask = topView.autoresizingMask
        let originalBottomViewAutoresizingMask = bottomView.autoresizingMask

        topView.autoresizingMask = []
        bottomView.autoresizingMask = []

        topView.frame = topViewFrame(containerBounds, !isPushing)
        bottomView.frame = bottomViewFrame(containerBounds, !isPushing)

        containerView.addSubview(destinationView)

        destinationView.setNeedsUpdateConstraints()
        destinationView.updateConstraintsIfNeeded()
        destinationView.setNeedsLayout()
        destinationView.layoutIfNeeded()
        
        let safeAreaBottomAndTop = destinationView.safeAreaInsets.top + destinationView.safeAreaInsets.bottom

        let preferredContentSize = CGSize(
            width: destinationViewController.preferredContentSize.width,
            height: destinationViewController.preferredContentSize.height + safeAreaBottomAndTop
        )

        var maxHeight = containerViewWindow.bounds.size.height - containerViewWindow.safeAreaInsets.top
        if case .visible(let appearance) = configuration.pullBar {
            maxHeight -= appearance.height
        }

        let targetSize = CGSize(
            width: preferredContentSize.width,
            height: min(preferredContentSize.height, maxHeight)
        )

        let navBarOffset = topView.safeAreaInsets.top
        let separatorFrame = CGRect(
            origin: CGPoint(
                x: topView.frame.origin.x,
                y: navBarOffset
            ),
            size: CGSize(
                width: pixelSize,
                height: containerBounds.size.height - navBarOffset
            )
        )
        let separatorView = UIView(frame: separatorFrame)
        separatorView.backgroundColor = .separator
        containerView.addSubview(separatorView)

        let animations = {
            let frame = CGRect(origin: .zero, size: targetSize)

            topView.frame = topViewFrame(isPushing ? frame : containerBounds, isPushing)
            topView.layoutIfNeeded()

            bottomView.frame = bottomViewFrame(frame, isPushing)
            bottomView.layoutIfNeeded()

            separatorView.frame = CGRect(
                origin: CGPoint(
                    x: topView.frame.origin.x,
                    y: navBarOffset
                ),
                size: separatorView.bounds.size
            )
        }

        let completion = { (isCompleted: Bool) in
            containerView.addSubview(bottomView)
            containerView.addSubview(topView)

            separatorView.removeFromSuperview()

            topView.autoresizingMask = originalTopViewAutoresizingMask
            bottomView.autoresizingMask = originalBottomViewAutoresizingMask

            transitionContext.completeTransition(isCompleted && !transitionContext.transitionWasCancelled)
        }

        let duration = transitionDuration(using: transitionContext)
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .curveLinear,
            animations: animations,
            completion: completion
        )
    }
}
