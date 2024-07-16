//
//  FailedLikingAlert.swift
//  MyCyprus
//
//  Created by Egor Kruglov on 22.07.2024.
//

import UIKit

protocol FailedLikingAlertProtocol where Self: UIViewController {
    var failedLikingHandler: (UIAlertAction) -> Void { get }
    func displayFailedLikingAlert() async
}

extension FailedLikingAlertProtocol {
    func displayFailedLikingAlert() async {
        let alertController = await UIAlertController(
            title: "Ooops 🫨",
            message: "Failed changing favourite status. Table will try to reload 🔄",
            preferredStyle: .alert
        )

        await alertController.addAction(
            .init(
                title: "okaaaaay let's go",
                style: .default,
                handler: failedLikingHandler
            )
        )

        await present(alertController, animated: true)
    }
}
