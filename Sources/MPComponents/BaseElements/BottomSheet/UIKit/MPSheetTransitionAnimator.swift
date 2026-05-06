//
//  MPSheetTransitionAnimator.swift
//  MPComponents
//

import UIKit

final class MPSheetTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let isPresenting: Bool

    init(isPresenting: Bool) { self.isPresenting = isPresenting }

    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval { 0.35 }

    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
        if self.isPresenting {
            self.animatePresentation(ctx)
        } else {
            self.animateDismissal(ctx)
        }
    }

    private func animatePresentation(_ ctx: UIViewControllerContextTransitioning) {
        guard let toVC = ctx.viewController(forKey: .to), let toView = ctx.view(forKey: .to) else { return }
        let finalFrame = ctx.finalFrame(for: toVC)
        ctx.containerView.addSubview(toView)
        toView.frame = finalFrame.offsetBy(dx: 0, dy: finalFrame.height)
        UIView.animate(
            withDuration: self.transitionDuration(using: ctx),
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.3,
            options: .curveEaseOut
        ) {
            toView.frame = finalFrame
        } completion: { _ in
            ctx.completeTransition(!ctx.transitionWasCancelled)
        }
    }

    private func animateDismissal(_ ctx: UIViewControllerContextTransitioning) {
        guard let fromView = ctx.view(forKey: .from) else { return }
        UIView.animate(
            withDuration: self.transitionDuration(using: ctx),
            delay: 0.15,
            options: .curveEaseIn
        ) {
            fromView.frame = fromView.frame.offsetBy(dx: 0, dy: fromView.frame.height)
        } completion: { _ in
            ctx.completeTransition(!ctx.transitionWasCancelled)
        }
    }
}
