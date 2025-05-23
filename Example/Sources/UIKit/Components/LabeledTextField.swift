//
//  LabeledTextField.swift
//  Example
//
//  Created by Guilherme Prata Costa on 27/02/25.
//
import UIKit

final class LabeledTextField: UIView {
    let titleLabel = UILabel()
    let containerView = UIView()

    init(title: String) {
        super.init(frame: .zero)
        self.setupView(title: title)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(title: String) {
        self.titleLabel.text = title
        self.titleLabel.font = UIFont.systemFont(ofSize: 14)
        self.titleLabel.textColor = .darkGray

        addSubview(self.titleLabel)
        addSubview(self.containerView)

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: topAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            self.containerView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 4),
            self.containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func addInputField(_ view: UIView) {
        self.containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            view.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)
        ])
    }
}
