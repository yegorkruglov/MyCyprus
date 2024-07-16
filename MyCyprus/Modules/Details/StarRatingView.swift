//
//  StarRatingView.swift
//  MyCyprus
//
//  Created by Egor Kruglov on 17.07.2024.
//

import UIKit

final class StarRatingView: UIView {
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 3.0
        stack.distribution = .fillEqually
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWith(_ rating: Int) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for index in 1...5 {
            let image = UIImage(systemName: "star.fill")
            let imageView = UIImageView(image: image)
            imageView.tintColor = index <= rating ? Colors.accentBlue : UIColor.lightGray
            stackView.addArrangedSubview(imageView)
        }
    }

    private func setupUI() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
