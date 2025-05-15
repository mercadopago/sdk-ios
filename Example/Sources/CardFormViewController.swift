import CoreMethods
import UIKit

/// A sample view controller demonstrating how to implement a credit card form using CoreMethods SDK
/// This example shows how to:
/// - Create and configure secure card fields
/// - Handle field validation and events
/// - Fetch payment information (documents, installments, payment methods)
/// - Create a payment token
final class CardFormViewController: UIViewController {
    // MARK: - Properties
    
    /// Style configuration for normal field state
    private let style = TextFieldDefaultStyle()
        .borderColor(.systemGray4).borderWidth(1).cornerRadius(12)
        .backgroundColor(.systemBackground)
        .font(.systemFont(ofSize: 16, weight: .regular))
        .textColor(.darkText)

    /// Style configuration for error field state
    private let errorStyle = TextFieldDefaultStyle()
        .borderColor(.systemRed).borderWidth(1).cornerRadius(12)
        .backgroundColor(.systemBackground)
        .font(.systemFont(ofSize: 16, weight: .regular))
        .textColor(.darkText)
    
    let paddingField = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))

    /// The CoreMethods instance for API calls
    private let coreMethods = CoreMethods()
    
    /// Payment amount to be processed
    private let amount: Double = 5000

    /// Available document types fetched from the API
    private var documents: [IdentificationType] = []
    
    /// Currently selected document type
    private var selectedDocumentType: IdentificationType?
    
    /// Token response text label
    private lazy var tokenResponseLabel: CopyableLabel = {
        let label = CopyableLabel()
        label.numberOfLines = 0
        label.textColor = .systemGreen
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.backgroundColor = .systemGray6
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        
        label.isUserInteractionEnabled = true
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        label.addGestureRecognizer(longPressGesture)

        return label
    }()

    // MARK: - UI Components
    
    /// Main container for all form elements
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    /// Main container for all form elements
    private lazy var stackView = buildStackView(axis: .vertical, spacing: 24)
    
    /// Container for security code and expiration date fields
    private lazy var cardDetailsStackView = buildStackView(axis: .horizontal, spacing: 16, distribution: .fillEqually)
    
    /// Container for document-related fields
    private lazy var documentSectionStackView = buildStackView(axis: .vertical, spacing: 16)

    /// Container for card number field with label
    private lazy var cardNumberContainer = LabeledTextField(title: "Card Number")
    
    /// Container for security code field with label
    private lazy var securityCodeContainer = LabeledTextField(title: "Security Code")
    
    /// Container for expiration date field with label
    private lazy var expirationDateContainer = LabeledTextField(title: "Expiration Date")

    /// Form section title for card details
    private lazy var cardSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Card Information"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()

    /// Card number input field with validation and formatting
    private lazy var cardNumberField: CardNumberTextField = {
        let field = CardNumberTextField(style: style)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.setPlaceholder("Enter card number")
        field.setLeftImage(view: paddingField)

        // Handle BIN number changes (first 6-8 digits)
        field.onBinChanged = { [weak self] bin in
            self?.searchInstallment(bin: bin)
            self?.searchPaymentMethod(bin: bin)
            DebugLogger.shared.log(type: .function, title: "onBinChanged", object: bin)
        }

        // Handle when the last 4 digits are filled
        field.onLastFourDigitsFilled = { [weak self] last in
            guard let self else { return }
            if field.isValid {
                self.setStyle(field, style: self.style)
            }
            print("Length:", field.count, "Last 4:", last)
            DebugLogger.shared.log(type: .function, title: "onLastFourDigitsFilled", object: last)
        }

        // Handle focus changes
        field.onFocusChanged = { [weak self] isFocused in
            print("CardNumberField Focus changed:", isFocused)
            DebugLogger.shared.log(type: .function, title: "onFocusChanged - CardNumberTextFieldView", object: isFocused)
        }

        // Handle validation errors
        field.onError = { [weak self] error in
            guard let self else { return }
            self.setStyle(field, style: self.errorStyle)
            print("CardNumberField Error:", error)
            DebugLogger.shared.log(type: .function, title: "onError - CardNumberTextFieldView", object: error)
        }

        return field
    }()

    /// Security code input field with validation
    private lazy var securityCodeField: SecurityCodeTextField = {
        let field = SecurityCodeTextField(style: style)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.setPlaceholder("CVV")
        field.setLeftImage(view: UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0)))

        // Handle when field is completely filled
        field.onInputFilled = { [weak self] in
            guard let self else { return }
            self.setStyle(field, style: self.style)
        }
        
        // Handle length changes
        field.onLengthChanged = { [weak self] length in
            print("SecurityCode length:", length)
            DebugLogger.shared.log(type: .function, title: "onLengthChanged - SecurityCodeTextField", object: length)
        }
        
        // Handle focus changes
        field.onFocusChanged = { [weak self] isFocused in
            print("SecurityCode Focus changed:", isFocused)
            DebugLogger.shared.log(type: .function, title: "onFocusChanged - SecurityCodeTextField", object: isFocused)
        }
        
        // Handle validation errors
        field.onError = { [weak self] error in
            guard let self else { return }
            self.setStyle(field, style: self.errorStyle)
            DebugLogger.shared.log(type: .function, title: "onError - SecurityCodeTextField", object: error)
        }

        return field
    }()

    /// Expiration date input field with validation and formatting
    private lazy var expirationDateField: ExpirationDateTextfield = {
        let field = ExpirationDateTextfield(style: style)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.setPlaceholder("MM/YYYY")
        field.setFormat(.long) // MM/YYYY format
        field.setLeftImage(view: UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0)))

        // Handle when field is completely filled
        field.onInputFilled = { [weak self] in
            guard let self else { return }
            self.setStyle(field, style: self.style)
        }
        
        // Handle length changes
        field.onLengthChanged = { [weak self] length in
            print("ExpirationDateTextfield length:", length)
            DebugLogger.shared.log(type: .function, title: "onLengthChanged - ExpirationDateTextfield", object: length)
        }
        
        // Handle focus changes
        field.onFocusChanged = { [weak self] isFocused in
            print("ExpirationDateTextfield Focus changed:", isFocused)
            DebugLogger.shared.log(type: .function, title: "onFocusChanged - ExpirationDateTextfield", object: isFocused)
        }
        
        // Handle validation errors
        field.onError = { [weak self] error in
            guard let self else { return }
            self.setStyle(field, style: self.errorStyle)
            DebugLogger.shared.log(type: .function, title: "onError - SecurityCodeTextField", object: error)
        }

        return field
    }()

    /// Document type selector with picker
    private lazy var documentTypeTextField: UITextField = {
        let tf = self.buildTextField(placeholder: "Select document type")
        tf.inputView = self.documentTypePicker
        tf.inputAccessoryView = self.makeToolbar()
        return tf
    }()

    /// Picker for document type selection
    private lazy var documentTypePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()

    /// Document number input field
    private lazy var documentNumberField = buildTextField(placeholder: "Enter document number", keyboard: .numberPad)

    /// Document section title
    private lazy var documentSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Document Information"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()

    /// Installment selection control
    private lazy var installmentPicker: InstallmentPickerView = {
        let picker = InstallmentPickerView()
        picker.delegate = self
        return picker
    }()
    
    /// Installment section title
    private lazy var installmentSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Payment Options"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()

    /// Pay button to submit the form
    private lazy var payButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pay", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(self.handlePayButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Card Payment"
        navigationController?.navigationBar.prefersLargeTitles = true
        self.setupView()
        self.getDocuments()
        self.cardNumberContainer.addInputField(self.cardNumberField)
        self.securityCodeContainer.addInputField(self.securityCodeField)
        self.expirationDateContainer.addInputField(self.expirationDateField)
    }

    // MARK: - UI Setup Methods
    
    /// Setup the main view and hierarchy
    private func setupView() {
        self.buildViewHierarchy()
        self.setupConstraints()
        view.backgroundColor = .systemBackground
    }

    /// Build the view hierarchy by adding subviews
    private func buildViewHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        self.cardDetailsStackView.addArrangedSubview(self.securityCodeContainer)
        self.cardDetailsStackView.addArrangedSubview(self.expirationDateContainer)

        self.documentSectionStackView.addArrangedSubview(self.documentTypeTextField)
        self.documentSectionStackView.addArrangedSubview(self.documentNumberField)

        [
            self.cardSectionLabel,
            self.cardNumberContainer,
            self.cardDetailsStackView,
            self.documentSectionLabel,
            self.documentSectionStackView,
            self.installmentSectionLabel,
            self.installmentPicker,
            self.tokenResponseLabel,
            self.payButton
        ].forEach { self.stackView.addArrangedSubview($0) }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -48),
            
            self.cardNumberField.heightAnchor.constraint(equalToConstant: 56),
            self.securityCodeField.heightAnchor.constraint(equalToConstant: 56),
            self.expirationDateField.heightAnchor.constraint(equalToConstant: 56),
            self.documentTypeTextField.heightAnchor.constraint(equalToConstant: 56),
            self.documentNumberField.heightAnchor.constraint(equalToConstant: 56),
            self.installmentPicker.heightAnchor.constraint(equalToConstant: 56),
            self.payButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func buildTextField(placeholder: String, keyboard: UIKeyboardType = .default) -> UITextField {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.borderStyle = .none
        tf.placeholder = placeholder
        tf.font = .systemFont(ofSize: 16)
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.systemGray4.cgColor
        tf.layer.cornerRadius = 12
        tf.textAlignment = .left
        tf.keyboardType = keyboard
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        tf.leftViewMode = .always
        tf.backgroundColor = .systemBackground
        return tf
    }

    private func buildStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat, distribution: UIStackView.Distribution = .fill) -> UIStackView {
        let stack = UIStackView()
        stack.axis = axis
        stack.spacing = spacing
        stack.alignment = .fill
        stack.distribution = distribution
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    private func makeToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonTapped))
        ]
        return toolbar
    }

    /// Handles the done button tap on toolbar
    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
}

// MARK: - Core Methods Integration

extension CardFormViewController {
    /// Handles the pay button tap
    /// Creates a token using the card information
    @objc private func handlePayButtonTapped() {
        Task {
            guard let selectedDocumentType else {
                let alert = UIAlertController(
                    title: "Missing Information",
                    message: "Please select a document type",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }

            // Test card holder name
            // For test payments, you can use these names to trigger different payment states:
            // - APRO: Payment approved
            // - OTHE: Payment Refused
            // - CONT: Pending payment
            // More info: https://www.mercadopago.com.br/developers/pt/docs/checkout-bricks/integration-test/test-payment-flow
            let cardHolder = "APRO"

            do {
                let token = try await coreMethods.createToken(
                    cardNumber: self.cardNumberField,
                    expirationDate: self.expirationDateField,
                    securityCode: self.securityCodeField,
                    documentType: selectedDocumentType,
                    documentNumber: self.documentNumberField.text ?? "",
                    cardHolderName: cardHolder
                )
                
                DebugLogger.shared.log(type: .network, title: "POST Create Token", object: token)

                // Display the token (in a real app, you would send this to your server)
                await MainActor.run {
                    tokenResponseLabel.text = "Token response => \(token.token)"
                }
            } catch {
                print("Error creating token: \(error)")
                
                let alert = UIAlertController(
                    title: "Payment Failed",
                    message: "Failed to process payment: \(error.localizedDescription)",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
        }
    }

    /// Fetches available document types from the API
    private func getDocuments() {
        Task(priority: .userInitiated) {
            do {
                // Fetch document types
                self.documents = try await self.coreMethods.identificationTypes()
                DebugLogger.shared.log(type: .network, title: "GET IdentificationTypes", object: self.documents)

                await MainActor.run {
                    // Update UI with document types
                    self.documentTypePicker.reloadAllComponents()
                    if let first = documents.first {
                        self.selectedDocumentType = first
                        self.documentTypeTextField.text = first.name
                    }
                }
            } catch {
                print("Error identifying documents:", error)
            }
        }
    }

    /// Fetches available installments for the given BIN
    /// - Parameter bin: The bank identification number (first 6-8 digits of card)
    func searchInstallment(bin: String) {
        Task {
            do {
                // Fetch installment options based on amount and card BIN
                let installment = try await coreMethods.installments(amount: self.amount, bin: bin)
                self.installmentPicker.updateInstallments(installment)
                
                DebugLogger.shared.log(type: .network, title: "GET Installment", object: installment)
            } catch {
                print("Error installments:", error)
            }
        }
    }

    /// Fetches payment method information for the given BIN
    /// - Parameter bin: The bank identification number (first 6-8 digits of card)
    func searchPaymentMethod(bin: String) {
        Task(priority: .userInitiated) {
            do {
                // Fetch payment method types based on card BIN
                let paymentMethod = try await coreMethods.paymentMethods(bin: bin)
                
                // Fetch issuer information base on id of payment method
                let issuer = try await coreMethods.issuers(bin: bin, paymentMethodID: paymentMethod.first?.id ?? "")

                DebugLogger.shared.log(type: .network, title: "GET PaymentMethods", object: paymentMethod)
                DebugLogger.shared.log(type: .network, title: "GET issuer", object: issuer)

                // Update UI with card logo
                if let thumbnail = paymentMethod.first?.thumbnail, !thumbnail.isEmpty {
                    await MainActor.run {
                        self.loadCardImage(from: thumbnail)
                    }
                }

                print("Payment methods:", paymentMethod)
                print("Issuer:", issuer)
            } catch {
                print("Error paymentMethod:", error)
            }
        }
    }
}

// MARK: - Style Helpers

extension CardFormViewController {
    /// Updates the style of a text field
    /// - Parameters:
    ///   - textfield: The field to update
    ///   - style: The style to apply
    func setStyle(_ textfield: PCITextField, style: TextFieldDefaultStyle) {
        textfield.setStyle(style)
    }
}

// MARK: Helpers
extension CardFormViewController {
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, let label = gesture.view as? CopyableLabel else { return }
        
        label.becomeFirstResponder()
        
        let menuController = UIMenuController.shared
        
        if #available(iOS 13.0, *) {
            menuController.showMenu(from: label, rect: label.bounds)
        } else {
            menuController.setTargetRect(label.bounds, in: label)
            menuController.setMenuVisible(true, animated: true)
        }
    }
    
    private func loadCardImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        // Separando a chamada do dataTask para evitar problemas de verificação de tipo
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil,
                  let image = UIImage(data: data) else {
                print("Error loading card image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let size = CGSize(width: 32, height: 32)
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            image.draw(in: CGRect(origin: .zero, size: size))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            DispatchQueue.main.async {
                let imageView = UIImageView(image: resizedImage)
                imageView.contentMode = .scaleAspectFit
                
                let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 32))
                containerView.backgroundColor = .clear
                
                imageView.translatesAutoresizingMaskIntoConstraints = false
                containerView.addSubview(imageView)
                
                NSLayoutConstraint.activate([
                    imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                    imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                    imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
                    imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
                ])
                
                self.cardNumberField.setRightImage(view: containerView)
            }
        }
        
        task.resume()
    }
}

// MARK: - PickerView Delegate & DataSource

extension CardFormViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int { 1 }
    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int { self.documents.count }
    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        self.documents[row].name
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        guard self.documents.indices.contains(row) else { return }
        self.selectedDocumentType = self.documents[row]
        self.documentTypeTextField.text = self.documents[row].name
        self.documentNumberField.placeholder = "Enter \(self.documents[row].name) number"
    }
}

// MARK: - InstallmentPicker Delegate
extension CardFormViewController: InstallmentPickerDelegate {
    func installmentPicker(_: InstallmentPickerView, didSelectPayerCost payerCost: Installment.PayerCost) {
        print("Selected installment:", payerCost.installments)
    }
}
