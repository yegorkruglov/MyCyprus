//
//  DetailsBuilder.swift
//  MyCyprus
//
//  Created by Egor Kruglov on 17.07.2024.
//

import Foundation

final class DetailsBuilder {
    func buildDetails() -> DetailsViewController {
        let presenter = DetailsPresenter()
        let networker = MyCyprusNetworker(api: MyCyprusApi())
        let interactor = DetailsInteractor(presenter: presenter, networker: networker)
        let viewController = DetailsViewController(interactor: interactor)
        presenter.viewController = viewController
        return viewController
    }
}
