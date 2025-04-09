//
//  PCITextField.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 28/01/25.
//

#if SWIFT_PACKAGE
    import MPCore
#endif
import UIKit

public class PCITextField: UIView {
    public typealias Style = PCIFieldStateStyleProtocol

    public var style: Style

    /// Returns whether the current input represents a valid field
    public var isValid: Bool {
        return self.input.isValid
    }

    /// The current number of digits entered in the field.
    public var count: Int {
        return self.input.count
    }

    // MARK: - Input Configuration

    /// A Boolean value indicating whether the field is enabled
    public var isEnabled: Bool {
        get { self.input.isEnabled }
        set { self.input.isEnabled = newValue }
    }

    /// The appearance of the keyboard that is associated with the text field
    public var keyboardAppearance: UIKeyboardAppearance {
        get { self.input.keyboardAppearance }
        set { self.input.keyboardAppearance = newValue }
    }

    let input: PCIFieldState

    private let contentType: UITextContentType?

    // MARK: - Initialization

    init(
        style: Style = TextFieldDefaultStyle(),
        configuration: PCIFieldState.Configuration,
        contentType: UITextContentType? = nil
    ) {
        self.style = style
        self.contentType = contentType
        self.input = PCIFieldState(configuration: configuration)
        self.input.setStyle(style)
        super.init(frame: .zero)
        buildLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ViewConfiguration Extensions

extension PCITextField: ViewConfiguration {
    package func buildViewHierarchy() {
        addSubview(self.input)
    }

    package func setupConstraints() {
        self.input.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.input.topAnchor.constraint(equalTo: topAnchor),
            self.input.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.input.trailingAnchor.constraint(equalTo: trailingAnchor),
            self.input.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    package func configureStyles() {
        self.input.setStyle(self.style)
    }

    package func configureAccessibility() {
        isAccessibilityElement = false
        self.input.textField.isAccessibilityElement = true
        self.input.textField.textContentType = self.contentType
        accessibilityElements = [self.input.textField]
    }
}

// MARK: - Public Methods

extension PCITextField {
    /// Sets the visual style of the text field.
    /// - Parameter style: The style configuration to be applied
    /// - Returns: Self for method chaining
    /// - Note: Style changes are applied immediately and will trigger a layout update
    @discardableResult
    public func setStyle(_ style: Style) -> Self {
        self.style = style
        self.input.setStyle(style)
        updateView()
        return self
    }

    /// Sets the placeholder text for the field
    /// - Parameter text: The placeholder text to display
    /// - Returns: Self for method chaining
    @discardableResult
    public func setPlaceholder(_ text: String) -> Self {
        self.input.setPlaceholder(text)
        return self
    }

    /// Sets a view to be displayed on the left side of the text field
    /// - Parameters:
    ///   - view: The view to be displayed
    ///   - mode: The mode determining when the view is visible
    /// - Returns: Self for method chaining
    @discardableResult
    public func setLeftImage(view: UIView, mode: UITextField.ViewMode = .always) -> Self {
        self.input.setLeftView(view, mode: mode)
        return self
    }

    /// Sets a view to be displayed on the right side of the text field
    /// - Parameters:
    ///   - view: The view to be displayed
    ///   - mode: The mode determining when the view is visible
    /// - Returns: Self for method chaining
    @discardableResult
    public func setRightImage(view: UIView, mode: UITextField.ViewMode = .always) -> Self {
        self.input.setRightView(view, mode: mode)
        return self
    }

    /// Clear text field
    public func clear() {
        self.input.clear()
    }
}
