//
//  NewsListPresenter.swift
//  NewsReader
//
//  Created by Aleksei Artamonov on 7/10/19.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

protocol NewsListPresenting {
    func presentNews(_ response: NewsList.ShowNews.Response)
    func presentError(_ error: Error)
}

final class NewsListPresenter: NewsListPresenting {
    weak var viewController: NewsListViewController?
    init(viewController: NewsListViewController) {
        self.viewController = viewController
    }
    let dateDecoder: DateFormatter = {
        let dateDecoder = DateFormatter()
        dateDecoder.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateDecoder
    }()
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    func presentNews(_ response: NewsList.ShowNews.Response) {
        var mappedArticles = [NewsList.ShowNews.ViewModel.FeedViewModel]()
        for article in response.articles {
            var dateString = ""
            if let date = dateDecoder.date(from: article.publishDate) {
                dateString = dateFormatter.string(from: date)
            }
            mappedArticles.append(NewsList.ShowNews.ViewModel.FeedViewModel(title: article.title, resource: article.resource, image: article.image ?? UIImage(), description: article.description, publishDate: dateString))
            
        }
        viewController?.displayNews(viewModel: NewsList.ShowNews.ViewModel(displayedFeeds: mappedArticles))
    }
    
    func presentError(_ error: Error) {
        viewController?.displayError(viewModel: NewsList.ShowError.ErrorViewModel(errorDescription: error.localizedDescription))
    }
}
