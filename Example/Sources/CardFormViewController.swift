import CoreMethods
import UIKit

final class CardFormViewController: UIViewController {
    private let style = TextFieldDefaultStyle()
        .borderColor(.systemGray).borderWidth(2).cornerRadius(8)

    private let errorStyle = TextFieldDefaultStyle()
        .borderColor(.red).borderWidth(2).cornerRadius(8)

    private let coreMethods = CoreMethods()
    private let amount: Double = 5000

    private var documents: [IdentificationType] = []
    private var selectedDocumentType: IdentificationType?

    private lazy var stackView = buildStackView(axis: .vertical, spacing: 16)
    private lazy var cardDetailsStackView = buildStackView(axis: .horizontal, spacing: 16, distribution: .fillEqually)
    private lazy var documentSectionStackView = buildStackView(axis: .vertical, spacing: 16)

    private lazy var cardNumberContainer = LabeledTextField(title: "Card Number")
    private lazy var securityCodeContainer = LabeledTextField(title: "Security Code")
    private lazy var expirationDateContainer = LabeledTextField(title: "Expiration Date")

    private lazy var cardNumberField: CardNumberTextField = {
        let field = CardNumberTextField(style: style)
        field.translatesAutoresizingMaskIntoConstraints = false

        field.onBinChanged = { [weak self] bin in
            self?.searchInstallment(bin: bin)
            self?.searchPaymentMethod(bin: bin)
        }

        field.onLastFourDigitsFilled = { [weak self] last in
            guard let self else { return }
            if field.isValid { field.setStyle(self.style) }
            print("Length:", field.count, "Last 4:", last)
        }

        field.onFocusChanged = { print("CardNumberField Focus changed:", $0) }

        field.onError = { [weak self] error in
            self?.cardNumberField.setStyle(self?.errorStyle ?? self!.style)
            print("CardNumberField Error:", error)
        }

        return field
    }()

    private lazy var securityCodeField: SecurityCodeTextField = {
        let field = SecurityCodeTextField(style: style)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.setPlaceholder("Insert security code")

        field.onInputFilled = { [weak self] in self?.setSecurityInputStyleDefault() }
        field.onLengthChanged = { print("SecurityCode length:", $0) }
        field.onFocusChanged = { print("SecurityCode Focus changed:", $0) }
        field.onError = { [weak self] _ in self?.setSecurityInputStyleError() }

        return field
    }()

    private lazy var expirationDateField: ExpirationDateTextfield = {
        let field = ExpirationDateTextfield(style: style)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.setPlaceholder("Insert date")
        field.setFormat(.long)

        field.onInputFilled = { print("Date completed") }
        field.onLengthChanged = { print("Date length:", $0) }
        field.onFocusChanged = { print("ExpirationDate Focus changed:", $0) }
        field.onError = { print("ExpirationDate Error:", $0) }

        return field
    }()

    private lazy var documentTypeTextField: UITextField = {
        let tf = self.buildTextField(placeholder: "Select document type")
        tf.inputView = self.documentTypePicker
        tf.inputAccessoryView = self.makeToolbar()
        return tf
    }()

    private lazy var documentTypePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()

    private lazy var documentNumberField = buildTextField(placeholder: "Enter document number", keyboard: .numberPad)

    private lazy var documentSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Document Information"
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()

    private lazy var installmentPicker: InstallmentPickerView = {
        let picker = InstallmentPickerView()
        picker.delegate = self
        return picker
    }()

    private lazy var payButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pay", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(self.handlePayButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.getDocuments()
        self.cardNumberContainer.addInputField(self.cardNumberField)
        self.securityCodeContainer.addInputField(self.securityCodeField)
        self.expirationDateContainer.addInputField(self.expirationDateField)
    }

    private func setupView() {
        self.buildViewHierarchy()
        self.setupConstraints()
        view.backgroundColor = .white
    }

    private func buildViewHierarchy() {
        view.addSubview(self.stackView)

        self.cardDetailsStackView.addArrangedSubview(self.securityCodeContainer)
        self.cardDetailsStackView.addArrangedSubview(self.expirationDateContainer)

        self.documentSectionStackView.addArrangedSubview(self.documentSectionLabel)
        self.documentSectionStackView.addArrangedSubview(self.documentTypeTextField)
        self.documentSectionStackView.addArrangedSubview(self.documentNumberField)

        [
            self.cardNumberContainer,
            self.cardDetailsStackView,
            self.documentSectionStackView,
            self.installmentPicker,
            self.payButton
        ].forEach { self.stackView.addArrangedSubview($0) }
    }

    private func setupConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            self.stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            self.stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            self.cardNumberField.heightAnchor.constraint(equalToConstant: 56),
            self.securityCodeField.heightAnchor.constraint(equalToConstant: 56),
            self.expirationDateField.heightAnchor.constraint(equalToConstant: 56),
            self.documentTypeTextField.heightAnchor.constraint(equalToConstant: 56),
            self.documentNumberField.heightAnchor.constraint(equalToConstant: 56),
            self.installmentPicker.heightAnchor.constraint(equalToConstant: 56),
            self.payButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func buildTextField(placeholder: String, keyboard: UIKeyboardType = .default) -> UITextField {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.borderStyle = .none
        tf.placeholder = placeholder
        tf.font = .systemFont(ofSize: 16)
        tf.layer.borderWidth = 2
        tf.layer.borderColor = UIColor.systemGray.cgColor
        tf.layer.cornerRadius = 8
        tf.textAlignment = .left
        tf.keyboardType = keyboard
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        tf.leftViewMode = .always
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

    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }

    @objc private func handlePayButtonTapped() {
        Task {
            let token = try await coreMethods.createToken(
                cardNumber: self.cardNumberField,
                expirationDate: self.expirationDateField,
                securityCode: self.securityCodeField
            )
            let label = UILabel()
            label.numberOfLines = 0
            label.text = "Token response => \(token.token)"
            self.stackView.addArrangedSubview(label)
        }
    }

    private func getDocuments() {
        Task(priority: .userInitiated) {
            do {
                self.documents = try await self.coreMethods.identificationTypes()
                await MainActor.run {
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

    func setSecurityInputStyleError() { self.securityCodeField.setStyle(self.errorStyle) }
    func setSecurityInputStyleDefault() { self.securityCodeField.setStyle(self.style) }

    func searchInstallment(bin: String) {
        Task {
            do {
                let installment = try await coreMethods.installments(amount: self.amount, bin: bin)
                self.installmentPicker.updateInstallments(installment)
            } catch {
                print("Error installments:", error)
            }
        }
    }

    func searchPaymentMethod(bin: String) {
        Task(priority: .userInitiated) {
            do {
                let paymentMethod = try await coreMethods.paymentMethods(bin: bin)
                let issuer = try await coreMethods.issuers(bin: bin, paymentMethodID: paymentMethod.first?.id ?? "")
                print("Payment methods:", paymentMethod)
                print("Issuer:", issuer)
            } catch {
                print("Error paymentMethod:", error)
            }
        }
    }
}

// MARK: - PickerView

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

// MARK: - InstallmentPickerDelegate

extension CardFormViewController: InstallmentPickerDelegate {
    func installmentPicker(_: InstallmentPickerView, didSelectPayerCost payerCost: Installment.PayerCost) {
        print("Installment:", payerCost.installments)
    }
}
