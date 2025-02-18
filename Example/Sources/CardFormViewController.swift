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

    private lazy var cardNumberField: CardNumberTextField = {
        let field = CardNumberTextField(style: style)
        field.translatesAutoresizingMaskIntoConstraints = false

        field.onBinChanged = { [weak self] bin in
            print("BIN changed: \(bin)")
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

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()

    private lazy var payButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pay", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.handlePayButtonTapped), for: .touchUpInside)

        return button
    }()

    private let coreMethods = CoreMethods()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    func setupView() {
        buildViewHierarchy()
        setupConstraints()
        configureStyles()
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
}

// MARK: - ViewConfiguration

extension CardFormViewController {
    func buildViewHierarchy() {
        view.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.cardNumberField)
        self.stackView.addArrangedSubview(self.securityCodeField)
        self.stackView.addArrangedSubview(self.expirationDateField)
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

            self.payButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    func configureStyles() {
        view.backgroundColor = .white
    }
}
