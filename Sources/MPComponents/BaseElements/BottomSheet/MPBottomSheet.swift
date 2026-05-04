//
//  MPBottomSheet.swift
//  MPComponents
//

import MPFoundation
import SwiftUI
import UIKit

// MARK: - MPBottomSheet

/// A bottom sheet component with two presentation modes.
///
/// **Options picker** — built-in trigger (picker label + chevron) and a list of selectable items:
/// ```swift
/// MPBottomSheet(
///     title: "Documento do titular",
///     options: viewModel.identificationTypes,
///     selected: $viewModel.selectTypeDocument
/// )
/// ```
///
/// **Custom content** — caller-provided trigger label and sheet body:
/// ```swift
/// MPBottomSheet(title: "Filtros") {
///     Image(systemName: "line.3.horizontal.decrease")
/// } content: {
///     FilterView()
/// }
/// ```
package struct MPBottomSheet: View {
    private let title: String
    private let height: CGFloat?
    @State private var isPresented = false

    private let makeTrigger: () -> AnyView
    private let makeContent: (@escaping () -> Void) -> AnyView

    // MARK: - Init: options picker

    package init<Option: MPBottomSheetListOption>(
        title: String,
        options: [Option],
        selected: Binding<Option?>
    ) {
        self.title = title
        self.height = Self.optionsHeight(count: options.count)
        self.makeTrigger = {
            AnyView(MPBottomSheetPickerLabel(selected: selected))
        }
        self.makeContent = { dismiss in
            AnyView(MPBottomSheetOptionsList(options: options, selected: selected, onDismiss: dismiss))
        }
    }

    // MARK: - Init: custom content

    package init(
        title: String,
        height: CGFloat? = nil,
        @ViewBuilder label: @escaping () -> some View,
        @ViewBuilder content: @escaping () -> some View
    ) {
        self.title = title
        self.height = height
        self.makeTrigger = { AnyView(label()) }
        self.makeContent = { _ in AnyView(content()) }
    }

    // MARK: - Body

    package var body: some View {
        Button { self.isPresented = true } label: {
            self.makeTrigger()
        }
        .buttonStyle(.plain)
        .bottomSheet(isPresented: self.$isPresented, title: self.title, height: self.height) {
            self.makeContent { self.isPresented = false }
        }
    }

    // MARK: - Height calculation

    /// Breakdown (theme values: xtiny=16, xmicro=8, micro=12):
    ///   drag indicator=20, header=40, each item=52, bottom (padding + safe area)=46
    private static func optionsHeight(count: Int) -> CGFloat {
        20 + 40 + CGFloat(count) * 52 + 46
    }
}

// MARK: - Private: Picker trigger label

private struct MPBottomSheetPickerLabel<Option: MPBottomSheetListOption>: View {
    @Binding var selected: Option?
    @Environment(\.checkoutTheme) private var theme: MPTheme

    var body: some View {
        HStack(spacing: 0) {
            Text(self.selected?.displayName ?? "")
                .textStyle(.bodyMedium(colorType: .secondary))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)

            Image(systemName: "chevron.down")
                .renderingMode(.template)
                .foregroundColor(self.theme.textFields.standard.idle.borderColor)
                .padding(.horizontal, self.theme.spacings.xmicro)
        }
        .padding(.leading, self.theme.spacings.micro)
        .animation(nil)
    }
}

// MARK: - Private: Options list

private struct MPBottomSheetOptionsList<Option: MPBottomSheetListOption>: View {
    let options: [Option]
    @Binding var selected: Option?
    let onDismiss: () -> Void
    @Environment(\.checkoutTheme) private var theme: MPTheme

    var body: some View {
        VStack(spacing: 0) {
            ForEach(self.options) { option in
                MPListItem(
                    isSelected: Binding(
                        get: { self.selected?.id == option.id },
                        set: { if $0 { self.selected = option
                            self.onDismiss()
                        } }
                    ),
                    contentInfo: MPListItemContentInfo(title: option.displayName)
                )
            }
        }
        .listItemStyle(.pick)
        .padding(.horizontal, self.theme.spacings.xnano)
        .padding(.bottom, self.theme.spacings.micro)
    }
}

// MARK: - Internal: Sheet content container

/// Visual container used by MPBottomSheetPresenter: drag indicator + header + scrollable content.
package struct MPBottomSheetContent<Content: View>: View {
    let title: String
    let onDismiss: () -> Void
    @ViewBuilder let content: () -> Content

    @Environment(\.checkoutTheme) private var theme: MPTheme

    package var body: some View {
        VStack(spacing: 0) {
            self.dragIndicator
            self.header
            ScrollView { self.content() }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(self.theme.colors.background.primary.edgesIgnoringSafeArea(.all))
    }

    private var dragIndicator: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: self.theme.borderRadius.full)
                .fill(self.theme.colors.icon.primary)
                .frame(width: 32, height: 4)
        }
        .frame(height: 20)
        .frame(maxWidth: .infinity)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(self.title).textStyle(.headingLarge())
            Spacer()
            Button(action: self.onDismiss) {
                Image(systemName: "xmark")
                    .renderingMode(.template)
                    .foregroundColor(self.theme.colors.icon.primary)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, self.theme.spacings.micro)
        .padding(.vertical, self.theme.spacings.xmicro)
        .background(self.theme.colors.background.primary)
    }
}

// MARK: - UIKit Presentation Controller

private final class MPSheetPresentationController: UIPresentationController {
    private let sheetHeight: CGFloat?
    private let dimmingView = UIView()
    var onDidDismiss: (() -> Void)?
    private var dismissNotified = false

    init(presentedViewController: UIViewController, presenting: UIViewController?, height: CGFloat?) {
        self.sheetHeight = height
        super.init(presentedViewController: presentedViewController, presenting: presenting)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView else { return .zero }
        let height = self.sheetHeight ?? containerView.bounds.height * 0.5
        return CGRect(x: 0, y: containerView.bounds.height - height, width: containerView.bounds.width, height: height)
    }

    override func presentationTransitionWillBegin() {
        guard let containerView else { return }
        self.dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.dimmingView.alpha = 0
        self.dimmingView.frame = containerView.bounds
        containerView.insertSubview(self.dimmingView, at: 0)
        self.dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dimmingTapped)))
        presentedViewController.transitionCoordinator?.animate { _ in self.dimmingView.alpha = 1 }
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
        presentedViewController.view.layer.cornerRadius = 20
        presentedViewController.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedViewController.view.layer.masksToBounds = true
    }

    @objc private func dimmingTapped() {
        self.dismissNotified = true
        self.onDidDismiss?()
        presentingViewController.dismiss(animated: true)
    }
}

// MARK: - Transition Animator

private final class MPSheetTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let isPresenting: Bool
    init(isPresenting: Bool) { self.isPresenting = isPresenting }
    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval { 0.35 }

    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
        if self.isPresenting {
            guard let toVC = ctx.viewController(forKey: .to), let toView = ctx.view(forKey: .to) else { return }
            let final = ctx.finalFrame(for: toVC)
            ctx.containerView.addSubview(toView)
            toView.frame = final.offsetBy(dx: 0, dy: final.height)
            UIView.animate(
                withDuration: self.transitionDuration(using: ctx),
                delay: 0,
                usingSpringWithDamping: 0.85,
                initialSpringVelocity: 0.3,
                options: .curveEaseOut
            ) {
                toView.frame = final
            } completion: { _ in ctx.completeTransition(!ctx.transitionWasCancelled) }
        } else {
            guard let fromView = ctx.view(forKey: .from) else { return }
            UIView.animate(withDuration: self.transitionDuration(using: ctx), delay: 0, options: .curveEaseIn) {
                fromView.frame = fromView.frame.offsetBy(dx: 0, dy: fromView.frame.height)
            } completion: { _ in ctx.completeTransition(!ctx.transitionWasCancelled) }
        }
    }
}

// MARK: - UIKit Presenter (UIViewControllerRepresentable)

struct MPBottomSheetPresenter<Content: View>: UIViewControllerRepresentable {
    let isPresented: Binding<Bool>
    let title: String
    let height: CGFloat?
    let content: () -> Content

    func makeCoordinator() -> Coordinator { Coordinator(self.isPresented, height: self.height) }

    func makeUIViewController(context _: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        return vc
    }

    func updateUIViewController(_ backgroundVC: UIViewController, context: Context) {
        if self.isPresented.wrappedValue {
            if let existing = context.coordinator.presentedController as? MPAutoUpdateHostingController<MPBottomSheetContent<Content>>,
               backgroundVC.presentedViewController === existing {
                existing.rootView = MPBottomSheetContent(title: self.title, onDismiss: { self.isPresented.wrappedValue = false }, content: self.content)
                return
            }
            guard backgroundVC.presentedViewController == nil else { return }

            let hostingVC = MPAutoUpdateHostingController(rootView: MPBottomSheetContent(
                title: title, onDismiss: { self.isPresented.wrappedValue = false }, content: content
            ))
            hostingVC.modalPresentationStyle = .custom
            hostingVC.transitioningDelegate = context.coordinator
            context.coordinator.presentedController = hostingVC

            DispatchQueue.main.async {
                guard backgroundVC.view.window != nil, backgroundVC.presentedViewController == nil else { return }
                backgroundVC.present(hostingVC, animated: true)
            }
        } else {
            if let presented = backgroundVC.presentedViewController,
               presented === context.coordinator.presentedController,
               !presented.isBeingDismissed {
                presented.dismiss(animated: true)
            }
            context.coordinator.presentedController = nil
        }
    }
}

extension MPBottomSheetPresenter {
    final class Coordinator: NSObject, UIViewControllerTransitioningDelegate, UIAdaptivePresentationControllerDelegate {
        let isPresented: Binding<Bool>
        let height: CGFloat?
        weak var presentedController: UIViewController?

        init(_ isPresented: Binding<Bool>, height: CGFloat?) {
            self.isPresented = isPresented
            self.height = height
        }

        func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source _: UIViewController) -> UIPresentationController? {
            let ctrl = MPSheetPresentationController(presentedViewController: presented, presenting: presenting, height: height)
            ctrl.delegate = self
            ctrl.onDidDismiss = { [weak self] in
                self?.isPresented.wrappedValue = false
                self?.presentedController = nil
            }
            return ctrl
        }

        func animationController(forPresented _: UIViewController, presenting _: UIViewController, source _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            MPSheetTransitionAnimator(isPresenting: true)
        }

        func animationController(forDismissed _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            MPSheetTransitionAnimator(isPresenting: false)
        }
    }
}

// MARK: - View Extension

package extension View {
    /// Presents an `MPBottomSheet` edge-to-edge via custom `UIPresentationController`.
    /// Compatible with iOS 13+.
    func bottomSheet(
        isPresented: Binding<Bool>,
        title: String,
        height: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        background(MPBottomSheetPresenter(isPresented: isPresented, title: title, height: height, content: content))
    }
}
