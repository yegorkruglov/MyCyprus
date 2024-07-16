//
//  CatalogPresenter.swift
//  MyCyprus
//
//  Created by Egor Kruglov on 16.07.2024.
//

import UIKit

final class CatalogPresenter {

    // MARK: - dependencies

    weak var viewController: CatalogViewController?

    // MARK: - private properties

    private var shouldShowAll: Bool = true

    // MARK: - public funcs

    func process(_ organizations: [Organization]) async {
        var sectionSnapshot: NSDiffableDataSourceSectionSnapshot<Organization> = .init()

        let result: [Organization]
        shouldShowAll
        ? (result = organizations)
        : (result = organizations.filter { $0.isFavorite })

        sectionSnapshot.append(result)
        await viewController?.display(sectionSnapshot)
    }

    func switchFilter(_ shouldShowAll: Bool) {
        self.shouldShowAll = shouldShowAll
    }

    func process(_ error: Error) async {
        guard let error = error as? NetworkError, error == NetworkError.handlingFavouriteFailed
        else {
            print(error.localizedDescription)
            return
        }

        await viewController?.displayFailedLikingAlert()
    }
}
