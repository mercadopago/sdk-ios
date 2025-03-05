//
//  InstallmentPickerView.swift
//  Example
//
//  Created by Guilherme Prata Costa on 05/03/25.
//

import CoreMethods
import UIKit

// MARK: - InstallmentPickerDelegate

protocol InstallmentPickerDelegate: AnyObject {
    func installmentPicker(_ picker: InstallmentPickerView, didSelectPayerCost payerCost: Installment.PayerCost)
}

// MARK: - InstallmentPickerView

class InstallmentPickerView: UIView {
    // MARK: - Properties

    private var installments: [Installment] = []
    private var flattenedPayerCosts: [Installment.PayerCost] = []
    private var selectedPayerCost: Installment.PayerCost?

    weak var delegate: InstallmentPickerDelegate?

    // MARK: - UI Elements

    private lazy var installmentTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .none
        textField.placeholder = "Select Installment"
        textField.textAlignment = .left
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.systemGray.cgColor
        textField.layer.cornerRadius = 8

        // Add left padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always

        // Set picker as input view
        textField.inputView = self.installmentPicker

        // Add toolbar with done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexSpace, doneButton]
        textField.inputAccessoryView = toolbar

        return textField
    }()

    private lazy var installmentPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()

    // MARK: - Initialization

    init(installments: [Installment] = []) {
        self.installments = installments
        super.init(frame: .zero)
        self.setupViews()
        self.setupPayerCosts()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
    }

    // MARK: - Setup

    private func setupViews() {
        addSubview(self.installmentTextField)

        NSLayoutConstraint.activate([
            self.installmentTextField.topAnchor.constraint(equalTo: topAnchor),
            self.installmentTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.installmentTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            self.installmentTextField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupPayerCosts() {
        // Flatten all payerCosts from all installments for easier display
        self.flattenedPayerCosts = self.installments.flatMap(\.payerCosts)
            .sorted { $0.installments < $1.installments }

        // Set default selected option to 1 installment if available
        selectedPayerCost = self.flattenedPayerCosts.first { $0.installments == 1 } ?? self.flattenedPayerCosts.first

        self.installmentPicker.reloadAllComponents()

        // Set initial selection and update textfield
        if let selectedPayerCost,
           let index = flattenedPayerCosts.firstIndex(where: { $0.installments == selectedPayerCost.installments }) {
            self.installmentPicker.selectRow(index, inComponent: 0, animated: false)
            self.updateTextFieldValue()
        }
    }

    // MARK: - Actions

    @objc private func doneButtonTapped() {
        self.updateTextFieldValue()
        endEditing(true)

        if let selectedPayerCost {
            self.delegate?.installmentPicker(self, didSelectPayerCost: selectedPayerCost)
        }
    }

    private func updateTextFieldValue() {
        if let payerCost = selectedPayerCost {
            self.installmentTextField.text = "\(payerCost.installments)x of \(payerCost.installmentAmount)"
        } else {
            self.installmentTextField.text = nil
        }
    }

    // MARK: - Public Methods

    /// Update the installments data
    func updateInstallments(_ installments: [Installment]) {
        self.installments = installments
        self.setupPayerCosts()
    }

    /// Select a specific payer cost programmatically
    func selectPayerCost(with installmentCount: Int, animated: Bool = true) {
        if let index = flattenedPayerCosts.firstIndex(where: { $0.installments == installmentCount }) {
            self.selectedPayerCost = self.flattenedPayerCosts[index]
            self.installmentPicker.selectRow(index, inComponent: 0, animated: animated)
            self.updateTextFieldValue()
        }
    }

    /// Get the currently selected payer cost
    func getSelectedPayerCost() -> Installment.PayerCost? {
        return self.selectedPayerCost
    }
}

// MARK: - UIPickerViewDataSource

extension InstallmentPickerView: UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return self.flattenedPayerCosts.count
    }
}

// MARK: - UIPickerViewDelegate

extension InstallmentPickerView: UIPickerViewDelegate {
    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        let payerCost = self.flattenedPayerCosts[row]
        return "\(payerCost.installments)x de \(payerCost.installmentAmount)"
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        guard row < self.flattenedPayerCosts.count else { return }
        self.selectedPayerCost = self.flattenedPayerCosts[row]
    }

    func pickerView(_: UIPickerView, rowHeightForComponent _: Int) -> CGFloat {
        return 50
    }
}
