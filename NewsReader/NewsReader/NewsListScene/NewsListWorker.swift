//
//  NewsListWorker.swift
//  NewsReader
//
//  Created by Aleksei Artamonov on 7/10/19.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit
import Kingfisher
import Foundation


protocol NewsListWorking {
    func getNewsList(with request: NewsList.ShowNews.Request, completion: @escaping (Result<[Article], Error>) -> Void)
    func loadImage(with url: URL, completion: @escaping (UIImage?) -> Void)
}

final class NewsListWorker: NewsListWorking {
    
    private let newsLoader: NewsLoading
    
    init(newsLoader: NewsLoading) {
        self.newsLoader = newsLoader
    }
    
    func getNewsList(with request: NewsList.ShowNews.Request, completion: @escaping (Result<[Article], Error>) -> Void) {
        newsLoader.loadNews(with: request.keyWord, completion: completion)
    }
    
    func loadImage(with url: URL, completion: @escaping (UIImage?) -> Void) {
        let cache = ImageCache.default
        let key = url.absoluteString
        if cache.isCached(forKey: key) {
            cache.retrieveImage(forKey: key, options: nil) { (imageResult) in
                switch imageResult {
                case .success(let result):
                    completion(result.image)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(nil)
                }
            }
        } else {
            ImageDownloader.default.downloadImage(with: url, options: nil, progressBlock: nil) { (imageLoadingResult) in
                DispatchQueue.main.async {
                    switch imageLoadingResult {
                    case .success(let result):
                        cache.store(result.image, forKey: key)
                        completion(result.image)
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        completion(nil)
                    }
                }
            }
        }
    }
}
