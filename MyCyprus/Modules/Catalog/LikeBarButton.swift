//
//  LikeBarButton.swift
//  MyCyprus
//
//  Created by Egor Kruglov on 22.07.2024.
//

import UIKit

protocol LikeBarButtonDelegate: AnyObject {
    func didTapLikeBarButton()
}

final class LikeBarButton: UIView {

    // MARK: - dependencies

    weak var delegate: LikeBarButtonDelegate?

    // MARK: - private properties

    private var counter: Int = 0

    // MARK: - ui

    private lazy var button: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        button.configuration = config
        button.addAction(
            UIAction(
                handler: { [weak self] _ in
                    guard let self, let delegate else { return }
                    delegate.didTapLikeBarButton()
                }
            ),
            for: .touchUpInside
        )
        button.tintColor = Colors.accentBlue
        return button
    }()
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold, width: .compressed)
        label.textColor = Colors.accentBlue

        label.isUserInteractionEnabled = false
        return label
    }()

    // MARK: - initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - public funcs

    func configureAs(_ shouldBeFilled: Bool) {
        button.setImage(
            UIImage(systemName: shouldBeFilled ? "heart.fill" : "heart"),
            for: .normal
        )
        label.textColor = shouldBeFilled ? .white : Colors.accentBlue
    }

    func configureCounter(value: Int) {
        counter = value
        value > 0
        ? (label.text = String(value))
        : (label.text = "0")
    }

    func handleValue(_ shouldIncrement: Bool) {
        shouldIncrement ? (counter += 1) : (counter -= 1)
        label.text = String(counter)
    }

    // MARK: - private funcs

    private func setup() {
        addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalTo(button)
        }
    }
}
