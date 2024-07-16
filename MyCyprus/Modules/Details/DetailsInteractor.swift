//
//  DetailsInteractor.swift
//  MyCyprus
//
//  Created by Egor Kruglov on 17.07.2024.
//

import Foundation

final class DetailsInteractor {

    // MARK: - dependencies

    private let presenter: DetailsPresenter
    private let networker: MyCyprusNetworker

    // MARK: - Initializer

    init(presenter: DetailsPresenter, networker: MyCyprusNetworker) {
        self.presenter = presenter
        self.networker = networker
    }

    func requestInfoForOrganizationWithId(_ id: Int) {
        Task {
            do {
                let organizationInfo = try await networker.loadOrganizationInfoWithId(id)
                await presenter.process(organizationInfo)
            } catch {
                await presenter.process(error)
            }
        }
    }

    func didTapLikeButton(_ organizationInfo: OrganizationInfo) {
        Task {
            do {
                try await networker.didTapLikeOrganizationWith(
                    id: organizationInfo.id,
                    oldStatus: organizationInfo.isFavorite
                )
                requestInfoForOrganizationWithId(organizationInfo.id)
            } catch {
                await presenter.process(error)
            }
        }
    }
}
