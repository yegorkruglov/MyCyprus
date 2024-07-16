//
//  CatalogInteractor.swift
//  MyCyprus
//
//  Created by Egor Kruglov on 16.07.2024.
//

import Foundation

final class CatalogInteractor {

    private var lastResult: [Organization]?

    // MARK: - dependencies

    private let presenter: CatalogPresenter
    private let networker: MyCyprusNetworker

    // MARK: - initializer

    init(presenter: CatalogPresenter, networker: MyCyprusNetworker) {
        self.presenter = presenter
        self.networker = networker
    }

    // MARK: - public funcs

    func loadOrganizations() {
        Task {
            do {
                let organizations: [Organization] = try await networker.loadOrganizations()
                await MainActor.run {
                    lastResult = organizations
                }
                await presenter.process(organizations)
            } catch {
                await presenter.process(error)
            }
        }
    }

    func switchFilter(_ shouldShowAll: Bool) {
        presenter.switchFilter(shouldShowAll)
        guard let lastResult else {
            loadOrganizations()
            return
        }

        Task {
            await presenter.process(lastResult)
        }
    }

    func didTapLikeButton(_ organization: Organization) {
        Task {
            do {
                try await networker.didTapLikeOrganizationWith(
                    id: organization.id,
                    oldStatus: organization.isFavorite
                )
                loadOrganizations()
            } catch {
                await presenter.process(error)
            }
        }
    }
}
