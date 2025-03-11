//
//  CardFormViewController.swift
//  Example
//
//  Created by Guilherme Prata Costa on 16/01/25.
//

import CoreMethods
import UIKit

final class CardFormViewController: UIViewController {
    let style = TextFieldDefaultStyle()
        .borderColor(.systemGray)
        .borderWidth(2)
        .cornerRadius(8)

    let errorStyle = TextFieldDefaultStyle()
        .borderColor(.red)
        .borderWidth(2)
        .cornerRadius(8)

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()

    private lazy var cardNumberContainer: LabeledTextField = {
        let container = LabeledTextField(title: "Card Number")
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()

    private lazy var cardNumberField: CardNumberTextField = {
        let field = CardNumberTextField(style: style)
        field.translatesAutoresizingMaskIntoConstraints = false

        field.onBinChanged = { [weak self] bin in
            self?.searchInstallment(bin: bin)
            self?.searchPaymentMethod(bin: bin)
        }

        field.onLastFourDigitsFilled = { [weak self] lastFourDigits in
            guard let self else { return }
            if field.isValid {
                field.setStyle(self.style)
            }
            print("Length: ", field.count)
            print("onLastFourDigitsFilled: \(lastFourDigits)")
        }

        field.onFocusChanged = { [weak self] isFocused in
            print("CardNumberField Focus changed: \(isFocused)")
        }

        field.onError = { [weak self] error in
            guard let self else { return }
            field.setStyle(self.errorStyle)
            print("CardNumberField Error: \(error)")
        }

        return field
    }()

    /// Horizontal stack for security code and expiration date
    private lazy var cardDetailsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var securityCodeContainer: LabeledTextField = {
        let container = LabeledTextField(title: "Security Code")
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()

    private lazy var securityCodeField: SecurityCodeTextField = {
        let field = SecurityCodeTextField(style: style)
            .setPlaceholder("Insert security code")
        field.translatesAutoresizingMaskIntoConstraints = false

        field.onInputFilled = { [weak self] in
            guard let self else { return }
            self.setSecurityInputStyleDefault()

            print("Security code completed")
        }

        field.onLengthChanged = { [weak self] length in
            print("onLengthChanged: \(length)")
        }

        field.onFocusChanged = { [weak self] isFocused in
            print("SecurityCodeField Focus changed: \(isFocused)")
        }

        field.onError = { [weak self] error in
            guard let self else { return }

            self.setSecurityInputStyleError()
            print("SecurityCodeField Error: \(error)")
        }

        return field
    }()

    private lazy var expirationDateContainer: LabeledTextField = {
        let container = LabeledTextField(title: "Expiration Date")
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()

    private lazy var expirationDateField: ExpirationDateTextfield = {
        let field = ExpirationDateTextfield(style: style)
            .setPlaceholder("Insert date")
        field.translatesAutoresizingMaskIntoConstraints = false
        field.setFormat(.long)

        field.onInputFilled = { [weak self] in
            guard let self else { return }
            self.setDateInputStyleDefault()

            print("Date completed")
        }

        field.onLengthChanged = { [weak self] length in
            print("onLengthChanged: \(length)")
        }

        field.onFocusChanged = { [weak self] isFocused in
            print("ExpirationDateTextfield Focus changed: \(isFocused)")
        }

        field.onError = { [weak self] error in
            guard let self else { return }

            self.setDateInputStyleError()
            print("ExpirationDateTextfield Error: \(error)")
        }

        return field
    }()

    private lazy var documentTypeTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .none
        textField.placeholder = "Select document type"
        textField.textAlignment = .left
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.systemGray.cgColor
        textField.layer.cornerRadius = 8

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always

        textField.inputView = self.documentTypePicker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexSpace, doneButton]
        textField.inputAccessoryView = toolbar

        return textField
    }()

    private lazy var documentTypePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()

    private lazy var documentNumberField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .none
        textField.placeholder = "Enter document number"
        textField.textAlignment = .left
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.systemGray.cgColor
        textField.layer.cornerRadius = 8
        textField.keyboardType = .numberPad

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always

        return textField
    }()

    private lazy var documentSectionStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var documentSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Document Information"
        label.font = UIFont.boldSystemFont(ofSize: 16)
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
        button.addTarget(self, action: #selector(self.handlePayButtonTapped), for: .touchUpInside)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8

        return button
    }()

    private let coreMethods = CoreMethods()

    var documents: [IdentificationType] = []
    var selectedDocumentType: IdentificationType?
    private let amount: Double = 5000

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.getDocuments()

        self.cardNumberContainer.addInputField(self.cardNumberField)
        self.securityCodeContainer.addInputField(self.securityCodeField)
        self.expirationDateContainer.addInputField(self.expirationDateField)
    }

    func setupView() {
        buildViewHierarchy()
        setupConstraints()
        configureStyles()
    }

    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }

    func setCardInputStyleError() {
        self.cardNumberField.setStyle(self.errorStyle)
    }

    func setSecurityInputStyleError() {
        self.securityCodeField.setStyle(self.errorStyle)
    }

    func setSecurityInputStyleDefault() {
        self.securityCodeField.setStyle(self.style)
    }

    func setDateInputStyleError() {
        self.expirationDateField.setStyle(self.errorStyle)
    }

    func setDateInputStyleDefault() {
        self.expirationDateField.setStyle(self.style)
    }

    @objc
    func handlePayButtonTapped() {
        Task {
            let token = try await coreMethods.createToken(
                cardNumber: self.cardNumberField,
                expirationDate: self.expirationDateField,
                securityCode: self.securityCodeField
            )

            let label = UILabel()
            label.numberOfLines = 0
            label.text = """
                Token response => \(token.token)
            """

            self.stackView.addArrangedSubview(label)
        }
    }

    func getDocuments() {
        Task {
            do {
                self.documents = try await self.coreMethods.identificationTypes()

                await MainActor.run {
                    self.documentTypePicker.reloadAllComponents()

                    if let firstDocument = self.documents.first {
                        self.selectedDocumentType = firstDocument
                        self.documentTypeTextField.text = firstDocument.name
                    }
                }
            } catch {
                print("Error identifying documents: \(error)")
            }
        }
    }

    func searchInstallment(bin: String) {
        Task {
            do {
                let installment = try await coreMethods.installments(amount: self.amount, bin: bin)
                self.installmentPicker.updateInstallments(installment)
            } catch {
                print("Error installments: \(error)")
            }
        }
    }

    func searchPaymentMethod(bin: String) {
        Task {
            do {
                let paymentMethod = try await coreMethods.paymentMethods(bin: bin)
                print("Payment methods: \(paymentMethod)")
            } catch {
                print("Error paymentMethod: \(error)")
            }
        }
    }
}

// MARK: - ViewConfiguration

extension CardFormViewController {
    func buildViewHierarchy() {
        view.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.cardNumberContainer)

        self.cardDetailsStackView.addArrangedSubview(self.securityCodeContainer)
        self.cardDetailsStackView.addArrangedSubview(self.expirationDateContainer)
        self.stackView.addArrangedSubview(self.cardDetailsStackView)

        self.documentSectionStackView.addArrangedSubview(self.documentSectionLabel)
        self.documentSectionStackView.addArrangedSubview(self.documentTypeTextField)
        self.documentSectionStackView.addArrangedSubview(self.documentNumberField)

        self.stackView.addArrangedSubview(self.documentSectionStackView)

        self.stackView.addArrangedSubview(self.installmentPicker)

        self.stackView.addArrangedSubview(self.payButton)
    }

    func setupConstraints() {
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

    func configureStyles() {
        view.backgroundColor = .white
    }
}

// MARK: - UIPickerViewDelegate & UIPickerViewDataSource

extension CardFormViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return self.documents.count
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return self.documents[row].name
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        if self.documents.indices.contains(row) {
            self.selectedDocumentType = self.documents[row]
            self.documentTypeTextField.text = self.documents[row].name

            self.documentNumberField.placeholder = "Enter \(self.documents[row].name) number"
        }
    }
}

extension CardFormViewController: InstallmentPickerDelegate {
    func installmentPicker(_: InstallmentPickerView, didSelectPayerCost payerCost: Installment.PayerCost) {
        print("Installment: \(payerCost.installments)")
    }
}
