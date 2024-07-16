//
//  CatalogBuilder.swift
//  MyCyprus
//
//  Created by Egor Kruglov on 16.07.2024.
//

import Foundation

final class CatalogBuilder {
    func buildCatalog() -> CatalogViewController {
        let presenter = CatalogPresenter()
        let networker = MyCyprusNetworker(api: MyCyprusApi())
        let interactor = CatalogInteractor(presenter: presenter, networker: networker)
        let viewController = CatalogViewController(interactor: interactor)
        presenter.viewController = viewController
        return viewController
    }
}
