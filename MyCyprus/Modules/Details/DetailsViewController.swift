//
//  DetailsViewController.swift
//  MyCyprus
//
//  Created by Egor Kruglov on 17.07.2024.
//

import UIKit

final class DetailsViewController: UIViewController {

    private enum DetailsSection: Hashable {
        case main
    }

    private var organizationInfo: OrganizationInfo?

    // MARK: - dependencies

    private let interactor: DetailsInteractor

    // MARK: - ui

    private var cellRegistration: UICollectionView.CellRegistration<DetailsCell, String> = {
        UICollectionView.CellRegistration {
            // swiftlint:disable:next closure_parameter_position
            cell, _, url in
            cell.configureWith(url)
        }
    }()
    private lazy var dataSource: UICollectionViewDiffableDataSource<DetailsSection, String> = {
        UICollectionViewDiffableDataSource(collectionView: collectionView) {
            // swiftlint:disable:next closure_parameter_position
            [unowned self] collectionView, indexPath, url in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: url
            )
        }
    }()
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.startAnimating()
        view.hidesWhenStopped = true
        return view
    }()
    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewLayout = {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .absolute(400.0),
                heightDimension: .absolute(250.0)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = Size.viii
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary

            return UICollectionViewCompositionalLayout(section: section)
        }()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = false
        return collectionView
    }()
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: Size.xx, weight: .semibold)
        return nameLabel
    }()
    private lazy var likeButton: UIButton = {
        let button = UIButton(
            primaryAction: UIAction(
                handler: { [weak self] _ in
                    guard let self, let organizationInfo else { return }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    handleFavButtonImage(liked: !organizationInfo.isFavorite)
                    interactor.didTapLikeButton(organizationInfo)
                }
            )
        )
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = Colors.accentBlue
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return button
    }()
    private lazy var starRatingView: StarRatingView = {
        let view = StarRatingView()
        view.isHidden = true
        return view
    }()
    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.text = "4"
        label.textColor = .systemBlue
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.isHidden = true
        label.textColor = Colors.accentBlue
        return label
    }()
    private lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "2 км от вас"
        label.textColor = .gray
        label.isHidden = true
        return label
    }()
    private lazy var infoBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Size.xx
        view.backgroundColor = .systemBackground
        return view
    }()
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17.0, weight: .bold)
        label.text = "Description"
        return label
    }()
    private lazy var organizationDescription: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.textColor = .gray
        return label
    }()
    private lazy var descriptionBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20.0
        return view
    }()

    // MARK: - lifecycle

    init(interactor: DetailsInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - public funcs

    func configureWith(_ organization: Organization) {
        nameLabel.text = organization.name
        interactor.requestInfoForOrganizationWithId(organization.id)
    }

    func display(_ organizationInfo: OrganizationInfo) {
        self.organizationInfo = organizationInfo

        nameLabel.text = organizationInfo.name

        if let rate = organizationInfo.rate {
            starRatingView.configureWith(rate)
            ratingLabel.text = String(rate)
            starRatingView.isHidden = false
            ratingLabel.isHidden = false
        }

        if let distance = organizationInfo.distance {
            distanceLabel.text = "\(distance) km from you"
            distanceLabel.isHidden = false
        }

        if let detailedInfo = organizationInfo.detailedInfo {
            !detailedInfo.isEmpty
            ? (organizationDescription.text = detailedInfo)
            : (organizationDescription.text = "No description provided")
        }

        if !organizationInfo.photos.isEmpty {
            var sectionSnapshot: NSDiffableDataSourceSectionSnapshot<String> = .init()
            sectionSnapshot.append(organizationInfo.photos)
            dataSource.apply(sectionSnapshot, to: .main)
        }

        handleFavButtonImage(liked: organizationInfo.isFavorite)
        uiElements(shouldHide: false)
    }
}

// MARK: - private funcs

private extension DetailsViewController {
    func setup() {
        addViews()
        setupViews()
        makeConstraints()
    }

    func addViews() {
        view.addSubview(activityIndicator)
        view.addSubview(collectionView)

        view.addSubview(infoBackground)
        infoBackground.addSubview(nameLabel)
        infoBackground.addSubview(likeButton)
        infoBackground.addSubview(starRatingView)
        infoBackground.addSubview(ratingLabel)
        infoBackground.addSubview(distanceLabel)

        view.addSubview(descriptionBackground)
        descriptionBackground.addSubview(descriptionLabel)
        descriptionBackground.addSubview(organizationDescription)
    }

    func configureNavBar() {
        title = "Restraunts"
        navigationItem.leftBarButtonItem = .init(
            image: UIImage.init(systemName: "chevron.left"),
            primaryAction: .init(
                handler: { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                }
            )
        )
        navigationItem.leftBarButtonItem?.tintColor = Colors.accentBlue
    }

    func configureCollectionView() {
        collectionView.dataSource = dataSource
        var dataSourceSnapshot: NSDiffableDataSourceSnapshot<DetailsSection, String> = .init()
        dataSourceSnapshot.appendSections([.main])
        dataSourceSnapshot.appendItems([], toSection: .main)
        dataSource.apply(dataSourceSnapshot)
    }

    func setupViews() {
        view.backgroundColor = .systemGray6
        uiElements(shouldHide: true)
        configureNavBar()
        configureCollectionView()
    }

    func makeConstraints() {
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        collectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(250.0)
        }

        likeButton.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview().inset(Size.xvi)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(Size.xvi)
            make.trailing.equalTo(likeButton.snp.leading).offset(-Size.xvi)
        }

        starRatingView.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(Size.xvi)
            make.top.equalTo(nameLabel.snp.bottom).offset(Size.viii)
        }

        ratingLabel.snp.makeConstraints { make in
            make.centerY.equalTo(starRatingView)
            make.leading.equalTo(starRatingView.snp.trailing).offset(Size.viii)
        }

        distanceLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(Size.xvi)
        }

        infoBackground.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(collectionView.snp.bottom).offset(Size.viii)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(Size.xvi)
        }

        organizationDescription.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(Size.viii)
            make.horizontalEdges.equalToSuperview().inset(Size.xvi)
            make.bottom.equalToSuperview().inset(Size.xvi)
        }

        descriptionBackground.snp.makeConstraints { make in
            make.top.equalTo(infoBackground.snp.bottom).offset(Size.viii)
            make.horizontalEdges.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(Size.xvi)
        }
    }

    func handleFavButtonImage(liked: Bool) {
        let image = UIImage(systemName: liked ? "heart.fill" : "heart")
        likeButton.setImage(image, for: .normal)
    }

    func uiElements(shouldHide: Bool) {
        collectionView.isHidden = shouldHide
        infoBackground.isHidden = shouldHide
        descriptionBackground.isHidden = shouldHide
        shouldHide
        ? (activityIndicator.startAnimating())
        : (activityIndicator.stopAnimating())
    }
}

// MARK: -

extension DetailsViewController: FailedLikingAlertProtocol {
    var failedLikingHandler: (UIAlertAction) -> Void {
        { [weak self] _ in
            guard let self, let organizationInfo else { return }
            uiElements(shouldHide: true)
            interactor.requestInfoForOrganizationWithId(organizationInfo.id)
            dismiss(animated: true)
        }
    }
}
