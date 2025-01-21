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
            field.setStyle(self.style)

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

            field.setStyle(self.errorStyle)
            print("SecurityCodeField Error: \(error)")
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    func setupView() {
        buildViewHierarchy()
        setupConstraints()
        configureStyles()
    }
}

// MARK: - ViewConfiguration

extension CardFormViewController {
    func buildViewHierarchy() {
        view.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.cardNumberField)
        self.stackView.addArrangedSubview(self.securityCodeField)
    }

    func setupConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            self.stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            self.stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            self.cardNumberField.heightAnchor.constraint(equalToConstant: 56),
            self.securityCodeField.heightAnchor.constraint(equalToConstant: 56)

        ])
    }

    func configureStyles() {
        view.backgroundColor = .white
    }
}
