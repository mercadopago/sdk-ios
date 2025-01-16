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
        let field = CardNumberTextField()
        field.translatesAutoresizingMaskIntoConstraints = false

        // Configurando callbacks
        field.onBinChange = { [weak self] bin in
            print("BIN changed: \(bin)")
        }

        field.onComplete = { [weak self] lastFourDigits in
            print("Card Number complete: \(lastFourDigits)")
        }

        field.onFocusChange = { [weak self] isFocused in
            print("Focus changed: \(isFocused)")
        }

        field.onError = { [weak self] _ in
            print("Error: \(isFocused)")
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
