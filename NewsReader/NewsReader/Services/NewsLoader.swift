//
//  NewsLoader.swift
//  PhotoMaps
//
//  Created by Aleksei Artamonov on 7/2/18.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation

protocol NewsLoading {
    func loadNews(with searchString: String, completion: @escaping (Result<[Article], Error>) -> Void)
}

enum InternalError: Error, LocalizedError {
    case newsLoadingError (desctiption: String)
}

struct FeedServerResponse: Decodable {
    let status: String?
    let totalResults: Int?
    let articles: [Article]?
    
}

final class NewsLoader: NewsLoading {
    static let shared = NewsLoader()
    
    private enum Constants {
        static let urlStringWithKeywordFormat = "https://newsapi.org/v2/everything?%@language=ru&apiKey=a0e1bf45ecaf4b0c86025888cd60f06c"
        static let urlStringTopHeadlines = "https://newsapi.org/v2/top-headlines?country=ru&apiKey=a0e1bf45ecaf4b0c86025888cd60f06c"
        static let internalErrorMessage = "Что-то пошло не так"
        static let defaultSearchString = "разное"
    }
    
    func loadNews(with searchString: String, completion: @escaping (Result<[Article], Error>) -> Void) {
        DispatchQueue.global().async {
            guard self.isRefreshing == false else {
                print("Already run")
                return
            }
            self.isRefreshing = true
            
            let keyword = searchString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            var query = ""
            guard var url = URL(string: Constants.urlStringTopHeadlines) else {
                fatalError("unable to create url")
            }
            if let keyword = keyword, !keyword.isEmpty {
                query.append(String(format: "q=%@&", keyword))
                guard let queryUrl = URL(string: String(format: Constants.urlStringWithKeywordFormat, query)) else {
                    fatalError("unable to create url")
                }
                url = queryUrl
            }
            let dataTask = self.urlSession.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    self.isRefreshing = false
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    self.isRefreshing = false
                    completion(.failure(InternalError.newsLoadingError(desctiption: Constants.internalErrorMessage)))
                    return
                }
                
                do {
                    self.isRefreshing = false
                    let feedsResponse = try JSONDecoder().decode(FeedServerResponse.self, from: data)
                    completion(.success(feedsResponse.articles ?? []))
                } catch {
                    completion(.failure(InternalError.newsLoadingError(desctiption: Constants.internalErrorMessage)))
                    
                }
            }
            dataTask.resume();
        }
    }
    

    var urlSession: URLSession
    var isRefreshing: Bool

     init() {
        isRefreshing = false
        let sessionConfig = URLSessionConfiguration.default
        urlSession = URLSession(configuration: sessionConfig)       
    }
}
