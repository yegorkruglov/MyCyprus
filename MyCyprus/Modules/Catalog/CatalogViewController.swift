//
//  ViewController.swift
//  MyCyprus
//
//  Created by Egor Kruglov on 16.07.2024.
//

import UIKit
import SnapKit

final class CatalogViewController: UIViewController {

    enum CatalogSection: Hashable {
        case main
    }

    // MARK: - private prorperties

    private var shouldShowAll: Bool = true

    // MARK: - dependencies

    private let interactor: CatalogInteractor

    // MARK: - ui

    private lazy var layout: UICollectionViewLayout = {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(Size.catalogCellHeight)
        )

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)

        section.interGroupSpacing = Size.xvi

        return UICollectionViewCompositionalLayout(section: section)
    }()
    private var cellRegistration: UICollectionView.CellRegistration<CatalogCell, Organization> = {
        UICollectionView.CellRegistration {
            // swiftlint:disable:next closure_parameter_position
            cell, _, organization in
            cell.configureWith(organization)
        }
    }()
    private lazy var dataSource: UICollectionViewDiffableDataSource<CatalogSection, Organization> = {
        UICollectionViewDiffableDataSource(collectionView: collectionView) {
            // swiftlint:disable:next closure_parameter_position
            [unowned self] collectionView, indexPath, organization in
            let cell = collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: organization
            )
            cell.delegate = self
            return cell
        }
    }()
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.startAnimating()
        view.hidesWhenStopped = true
        return view
    }()
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        return collectionView
    }()
    private lazy var likeBarButton: LikeBarButton = {
        let button = LikeBarButton()
        button.delegate = self
        return button
    }()

    // MARK: - lifecycle

    init(interactor: CatalogInteractor) {
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        interactor.loadOrganizations()
    }

    // MARK: - public funcs

    func display(_ sectionSnapshot: NSDiffableDataSourceSectionSnapshot<Organization>) {
        activityIndicator.stopAnimating()
        collectionView.isHidden = false
        dataSource.apply(sectionSnapshot, to: .main, animatingDifferences: true)
        likeBarButton.configureCounter(value: sectionSnapshot.items.filter({ $0.isFavorite }).count)

        guard sectionSnapshot.items.isEmpty else { return }
        switchFilter()
    }
}

// MARK: - private funcs

private extension CatalogViewController {
    func setup() {
        addViews()
        setupViews()
        makeConstraints()
    }

    func addViews() {
        view.addSubview(activityIndicator)
        view.addSubview(collectionView)
    }

    func setupViews() {
        view.backgroundColor = .systemGray6
        collectionView.isHidden = true
        configureCollectionView()
        configureNavBar()
    }

    func makeConstraints() {
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    func configureCollectionView() {
        collectionView.backgroundColor = .clear

        var dataSourceSnapshot: NSDiffableDataSourceSnapshot<CatalogSection, Organization> = .init()
        dataSourceSnapshot.appendSections([.main])
        dataSourceSnapshot.appendItems([], toSection: .main)

        dataSource.apply(dataSourceSnapshot)
        collectionView.dataSource = dataSource
    }

    func configureNavBar() {
        title = "Restraunts"
        navigationItem.rightBarButtonItem = .init(customView: likeBarButton)
    }
}

// MARK: - UICollectionViewDelegate

extension CatalogViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let organization = dataSource.itemIdentifier(for: indexPath) else { return }
        let viewController = DetailsBuilder().buildDetails()
        viewController.configureWith(organization)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - CatalogCellDelegate

extension CatalogViewController: CatalogCellDelegate {
    func didTapLikeButton(_ organization: Organization) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        interactor.didTapLikeButton(organization)
        likeBarButton.handleValue(!organization.isFavorite)
    }
}

// MARK: - FailedLikingAlertProtocol

extension CatalogViewController: FailedLikingAlertProtocol {
    var failedLikingHandler: (UIAlertAction) -> Void {
        { [weak self] _ in
            self?.activityIndicator.startAnimating()
            self?.collectionView.isHidden = true
            self?.interactor.loadOrganizations()
            self?.dismiss(animated: true)
        }
    }
}

// MARK: - LikeBarButtonDelegate

extension CatalogViewController: LikeBarButtonDelegate {
    func didTapLikeBarButton() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        switchFilter()
    }

    func switchFilter() {
        likeBarButton.configureAs(shouldShowAll)
        shouldShowAll.toggle()
        interactor.switchFilter(shouldShowAll)
    }
}
