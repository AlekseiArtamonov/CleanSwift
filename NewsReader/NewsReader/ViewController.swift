//
//  ViewController.swift
//  NewsReader
//
//  Created by Aleksei Artamonov on 7/8/19.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

class ViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    private var displayedNews: NewsList.ShowNews.ViewModel

    func displayNews(viewModel: NewsList.ShowNews.ViewModel) {
        displayedNews = displayedNews.displayedFeeds
    }

}

