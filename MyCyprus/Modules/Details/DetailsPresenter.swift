//
//  DetailsPresenter.swift
//  MyCyprus
//
//  Created by Egor Kruglov on 17.07.2024.
//

import Foundation

final class DetailsPresenter {

    // MARK: - dependencies

    weak var viewController: DetailsViewController?

    func process(_ organizationInfo: OrganizationInfo) async {
        await viewController?.display(organizationInfo)
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
