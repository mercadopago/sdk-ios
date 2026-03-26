//
//  MPPopoverPresenter.swift
//  MPComponents
//

import SwiftUI
import UIKit

// MARK: - AutoUpdateSizeHostingController

final class MPAutoUpdateHostingController<Content: View>: UIHostingController<Content> {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        if #available(iOS 16.0, *) {
            // Must be [] — prevents UIHostingController from shrinking to content's ideal size.
            // PopoverController sets the frame via frameOfPresentedViewInContainerView (full screen).
            sizingOptions = []
        }
        if #available(iOS 16.4, *) {
            var regions = safeAreaRegions
            regions.remove(.keyboard)
            safeAreaRegions = regions
        }
    }
}

// MARK: - Touch Delegating View

/// Passes touches through to the presenting view while still firing dismiss gesture.
final class MPTouchDelegatingView: UIView {
    weak var backView: UIView?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else { return nil }
        if event != nil {
            gestureRecognizers?.first?.state = .ended
        }
        guard view === self, let converted = backView?.convert(point, from: self) else {
            return view
        }
        return self.backView?.hitTest(converted, with: event)
    }
}

// MARK: - Popover Presentation Controller

/// - Forces .popover on all size classes (prevents iPhone adapting to fullScreen/sheet)
/// - Covers the full screen — SwiftUI content positions the bubble itself
/// - Hides UIKit's _UICutoutShadowView artifact
final class MPPopoverController: UIPopoverPresentationController, UIPopoverPresentationControllerDelegate {
    private lazy var overlayView: MPTouchDelegatingView = {
        let view = MPTouchDelegatingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }()

    /// Force .popover on all size classes
    override func adaptivePresentationStyle(for traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        delegate?.adaptivePresentationStyle?(for: self, traitCollection: traitCollection) ?? self.adaptivePresentationStyle
    }

    func adaptivePresentationStyle(
        for _: UIPresentationController,
        traitCollection _: UITraitCollection
    ) -> UIModalPresentationStyle {
        .popover
    }

    /// Full-screen frame: SwiftUI handles its own bubble positioning via .position(x:y:)
    override var frameOfPresentedViewInContainerView: CGRect {
        containerView?.bounds ?? .zero
    }

    override func containerViewWillLayoutSubviews() {
        presentedViewController.view.frame = self.frameOfPresentedViewInContainerView
        self.overlayView.frame = containerView?.frame ?? .zero
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedViewController.view.frame = self.frameOfPresentedViewInContainerView
        containerView?.backgroundColor = .clear
        if let containerView {
            self.hideCutoutShadowView(in: containerView)
        }
    }

    override func presentationTransitionWillBegin() {
        // Don't call super — UIPopoverPresentationController.super adds unwanted popover chrome/arrow
        guard let containerView else { return }
        containerView.backgroundColor = .clear
        containerView.accessibilityViewIsModal = true
        // Dismiss on tap-outside is handled by SwiftUI (Color.clear.onTapGesture in MPPopoverFloatingContent).
        // The overlay exists only to pass touches through to underlying views (keyboard, text fields).
        self.overlayView.backView = presentingViewController.view
        containerView.insertSubview(self.overlayView, at: 0)

        // Safety: ensure the presented view is in the container
        let rootView = presentedViewController.view!
        if rootView.superview == nil {
            containerView.addSubview(rootView)
        }
        rootView.frame = self.frameOfPresentedViewInContainerView

        self.hideCutoutShadowView(in: containerView)
        containerView.window.map { self.hideCutoutShadowView(in: $0) }
    }

    private func hideCutoutShadowView(in view: UIView) {
        if NSStringFromClass(type(of: view)) == "_UICutoutShadowView" {
            view.isHidden = true
            return
        }
        view.subviews.forEach { self.hideCutoutShadowView(in: $0) }
    }
}

// MARK: - MPPopoverPresenter

/// Capture trigger frame
struct MPPopoverPresenter<Content: View>: UIViewControllerRepresentable {
    let isPresented: Binding<Bool>
    @ViewBuilder let content: Content

    func makeCoordinator() -> Coordinator {
        Coordinator(self.isPresented)
    }

    func makeUIViewController(context _: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        return vc
    }

    func updateUIViewController(_ backgroundVC: UIViewController, context: Context) {
        if self.isPresented.wrappedValue {
            // Already presented — just update content
            if let existing = context.coordinator.presentedController,
               backgroundVC.presentedViewController === existing {
                existing.rootView = self.content
                return
            }

            guard backgroundVC.presentedViewController == nil else { return }

            let contentVC = MPAutoUpdateHostingController(rootView: content)
            contentVC.modalPresentationStyle = .custom
            contentVC.transitioningDelegate = context.coordinator
            contentVC.view.backgroundColor = .clear
            context.coordinator.presentedController = contentVC

            // Defer to next run loop: SwiftUI may call updateUIViewController during a layout pass,
            // and UIKit silently ignores present() calls made during layout.
            DispatchQueue.main.async {
                guard backgroundVC.view.window != nil,
                      backgroundVC.presentedViewController == nil else { return }
                backgroundVC.present(contentVC, animated: false)
            }
        } else {
            if let presented = backgroundVC.presentedViewController as? MPAutoUpdateHostingController<Content>,
               presented === context.coordinator.presentedController {
                presented.dismiss(animated: false)
                context.coordinator.presentedController = nil
            }
        }
    }
}

// MARK: - Coordinator

extension MPPopoverPresenter {
    final class Coordinator: NSObject, UIViewControllerTransitioningDelegate {
        let isPresented: Binding<Bool>
        weak var presentedController: MPAutoUpdateHostingController<Content>?

        init(_ isPresented: Binding<Bool>) {
            self.isPresented = isPresented
        }

        func presentationController(
            forPresented presented: UIViewController,
            presenting: UIViewController?,
            source: UIViewController
        ) -> UIPresentationController? {
            let controller = MPPopoverController(
                presentedViewController: presented,
                presenting: presenting
            )
            controller.delegate = controller
            controller.sourceView = source.view
            return controller
        }
    }
}
