//
//  DetailsCell.swift
//  MyCyprus
//
//  Created by Egor Kruglov on 18.07.2024.
//

import UIKit
import SnapKit
import Kingfisher

final class DetailsCell: UICollectionViewCell {

    // MARK: - ui

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = Size.xx
        return view
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

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    func configureWith(_ url: String) {
        if let url = URL(string: url) {
            let processor = DownsamplingImageProcessor(size: imageView.bounds.size)
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(
                with: url,
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ]
            )
        }
    }
}

private extension DetailsCell {
    func setup() {
        addViews()
        setupViews()
        makeConstraints()
    }

    func addViews() {
        contentView.addSubview(imageView)
    }

    func setupViews() {
        layer.cornerRadius = Size.xx
        backgroundColor = .white
    }

    func makeConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
