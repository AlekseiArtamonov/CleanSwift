//
//  NewsListRouter.swift
//  NewsReader
//
//  Created by Aleksei Artamonov on 7/10/19.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

protocol NewsListRouting {
    func showError(message: String)
}

class NewsListRouter: BaseRouter {
    private enum Constants {
        static let errorTitle = "Что-то пошло не так"
        static let errorButton = "OK"
    }
    
}

extension NewsListRouter: NewsListRouting {
    func showError(message: String) {
        let alertController = UIAlertController(title: Constants.errorTitle, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Constants.errorButton, style: .cancel, handler: nil))
        viewController?.present(alertController, animated: true)
    }
}
