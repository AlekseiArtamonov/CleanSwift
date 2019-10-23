//
//  NewsListInteractor.swift
//  NewsReader
//
//  Created by Aleksei Artamonov on 7/10/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation

protocol NewsListInteracting: class {
    func getNewsList(request: NewsList.ShowNews.Request)
}

final class NewsListInteractor: NewsListInteracting {
    private var worker: NewsListWorking
    private var presenter: NewsListPresenting
    init(worker: NewsListWorking, presenter: NewsListPresenting) {
        self.worker = worker
        self.presenter = presenter
    }
    
    func getNewsList(request: NewsList.ShowNews.Request) {
        worker.getNewsList(with: request) { [weak self] (result) in
            switch result {
            case .success(var articles):
                let dispatchGroup = DispatchGroup()
                for (index, _) in articles.enumerated() {
                    guard let imageUrl = articles[index].imageUrl else {
                        continue
                    }
                    dispatchGroup.enter()
                    self?.worker.loadImage(with: imageUrl) { (image) in
                        articles[index].image = image
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    self?.presenter.presentNews(NewsList.ShowNews.Response(articles: articles))
                }
            
            case .failure(let error):
                self?.presenter.presentError(error)
            }
            
        }
    }
}
