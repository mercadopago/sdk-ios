//
//  CardFormViewController.swift
//  Example
//
//  Created by Guilherme Prata Costa on 16/01/25.
//

import CoreMethods
import UIKit

final class CardFormViewController: UIViewController {
    private lazy var cardNumberField: CardNumberTextField = {
        let style = TextFieldDefaultStyle()
            .borderColor(.systemGray)
            .borderWidth(2)
            .cornerRadius(8)

        let errorStyle = TextFieldDefaultStyle()
            .borderColor(.red)
            .borderWidth(2)
            .cornerRadius(8)

        let field = CardNumberTextField(style: style)
        field.translatesAutoresizingMaskIntoConstraints = false

        field.onBinChanged = { [weak self] bin in
            print("BIN changed: \(bin)")
        }

        field.onLastFourDigitsFilled = { [weak self] lastFourDigits in
            if field.isValid {
                field.setStyle(style)
            }
            print("Length: ", field.count)
            print("Card Number complete: \(lastFourDigits)")
        }

        field.onFocusChanged = { [weak self] isFocused in
            print("Focus changed: \(isFocused)")
        }

        field.onError = { [weak self] error in
            field.setStyle(errorStyle)
            print("Error: \(error)")
        }

        return field
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
        view.addSubview(self.cardNumberField)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            self.cardNumberField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            self.cardNumberField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            self.cardNumberField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            self.cardNumberField.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    func configureStyles() {
        view.backgroundColor = .white
    }
}
