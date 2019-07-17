//
//  NewsModels.swift
//  NewsReader
//
//  Created by Aleksei Artamonov on 7/10/19.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

enum NewsList {    
    enum ShowNews {
        struct Request {
            var keyWord: String
        }
        
        struct Response {
            var articles: [Article]
        }
        
        struct ViewModel {
            struct FeedViewModel {
                let title: String
                let resource: String
                let image: UIImage
                let description: String
                let publishDate: String
            }
            
            var displayedFeeds: [FeedViewModel]

        }
    }
    
    enum ShowError {
        struct Response {
            var result: Error
        }
        
        struct ErrorViewModel {
            let errorDescription: String
        }
    }
}
