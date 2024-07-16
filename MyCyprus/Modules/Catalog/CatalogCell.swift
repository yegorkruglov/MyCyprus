//
//  CatalogCell.swift
//  MyCyprus
//
//  Created by Egor Kruglov on 16.07.2024.
//

import UIKit
import SnapKit
import Kingfisher

protocol CatalogCellDelegate: AnyObject {
    func didTapLikeButton(_ organization: Organization)
}

final class CatalogCell: UICollectionViewCell {

    private(set) var organization: Organization?

    // MARK: - bdependencies

    weak var delegate: CatalogCellDelegate?

    // MARK: - ui

    private lazy var restrauntImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = Size.xx
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return imageView
    }()
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
        return nameLabel
    }()
    private lazy var starImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "star.fill")
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageView.tintColor = Colors.accentBlue
        return imageView
    }()
    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    private lazy var ratingStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [starImageView, ratingLabel])
        stack.axis = .horizontal
        stack.spacing = 4.0
        stack.distribution = .fill
        stack.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        stack.isHidden = true
        return stack
    }()
    private lazy var averageBillLabel: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.textColor = UIColor.gray
        label.isHidden = true
        return label
    }()
    private lazy var cuisinesLabel: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.textColor = UIColor.gray
        return label
    }()
    private lazy var infoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [ratingStack, averageBillLabel, cuisinesLabel])
        stack.axis = .horizontal
        stack.spacing = Size.viii
        stack.distribution = .fill
        return stack
    }()
    private lazy var likeButton: UIButton = {
        let button = UIButton(
            primaryAction: UIAction(
                handler: { [weak self] _ in
                    guard let self, let organization else { return }
                    handleFavButtonImage(liked: !organization.isFavorite)
                    delegate?.didTapLikeButton(organization)
                }
            )
        )
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = Colors.accentBlue
        return button
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

        restrauntImageView.image = nil
        nameLabel.text = nil
        ratingLabel.text = nil
        ratingStack.isHidden = true
        averageBillLabel.text = nil
        averageBillLabel.isHidden = true
        cuisinesLabel.text = nil
        organization = nil
    }

    // MARK: - public funcs

    func configureWith(_ organization: Organization) {
        self.organization = organization

        nameLabel.text = organization.name

        if let rate = organization.rate {
            ratingStack.isHidden = false
            ratingLabel.text = String(rate)
        }

        if !organization.averageCheck.isEmpty {
            let averageBill: Int = (organization.averageCheck.reduce(0, +)) / organization.averageCheck.count
            averageBillLabel.text = String(averageBill)
            averageBillLabel.isHidden = false
        }

        cuisinesLabel.text = organization.cuisines.formatted()

        if let url = URL(string: organization.photo) {
            let processor = DownsamplingImageProcessor(size: restrauntImageView.bounds.size)
            restrauntImageView.kf.indicatorType = .activity
            restrauntImageView.kf.setImage(
                with: url,
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ]
            )
        }

        handleFavButtonImage(liked: organization.isFavorite)
    }
}

// MARK: - private funcs

private extension CatalogCell {
    func setup() {
        addViews()
        setupViews()
        makeConstraints()
    }

    func addViews() {
        contentView.addSubview(restrauntImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(likeButton)
        contentView.addSubview(infoStack)
    }

    func setupViews() {
        layer.cornerRadius = Size.xx
        backgroundColor = .systemBackground
    }

    func makeConstraints() {
        restrauntImageView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(Size.imageHeight)
        }

        infoStack.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(Size.xvi)
            make.bottom.equalToSuperview().inset(15.0)
        }

        likeButton.snp.makeConstraints { make in
            make.size.equalTo(Size.xxiv)
            make.bottom.equalTo(infoStack.snp.top).offset(-Size.viii)
            make.trailing.equalTo(infoStack)
        }

        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton)
            make.leading.equalTo(infoStack)
            make.trailing.equalTo(likeButton.snp.leading).inset(-Size.xvi)
        }
    }

    func handleFavButtonImage(liked: Bool) {
        let image = UIImage(systemName: liked ? "heart.fill" : "heart")
        likeButton.setImage(image, for: .normal)
    }
}
