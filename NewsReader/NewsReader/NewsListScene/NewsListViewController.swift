//
//  NewsListViewController.swift
//  NewsReader
//
//  Created by Aleksei Artamonov on 7/10/19.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

class NewsListViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    var searchBar: UISearchBar?
    
    var interactor: NewsListInteracting?
    var router: NewsListRouting?
    private var displayedNews: [NewsList.ShowNews.ViewModel.FeedViewModel] = []
    private lazy var lazySearch: ((String) -> Void) = {
        return debounce(delay: DispatchTimeInterval.milliseconds(300)) { [weak self] (searchString) in
            self?.interactor?.getNewsList(request: NewsList.ShowNews.Request(keyWord: searchString))
        }
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(NewsListViewController.refreshOnControl(_:)), for: .valueChanged)
        refreshControl.tintColor = .blue
        tableView.refreshControl = refreshControl
        
        interactor?.getNewsList(request: NewsList.ShowNews.Request(keyWord: searchBar?.text ?? ""))
    }
    
    @objc
    func refreshOnControl(_ sender: UIRefreshControl) {
        interactor?.getNewsList(request: NewsList.ShowNews.Request(keyWord: searchBar?.text ?? ""))
    }
    
    func displayNews(viewModel: NewsList.ShowNews.ViewModel) {
        DispatchQueue.main.async {
            self.displayedNews = viewModel.displayedFeeds
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    func displayError(viewModel: NewsList.ShowError.ErrorViewModel) {
        DispatchQueue.main.async {
            self.router?.showError(message: viewModel.errorDescription)
        }
    }

    
    private func setup() {
        let newsListWorker = NewsListWorker(newsLoader: NewsLoader.shared)
        let newsListPresenter = NewsListPresenter(viewController: self)
        interactor = NewsListInteractor(worker: newsListWorker, presenter: newsListPresenter)
        router = NewsListRouter(with: self)
        searchBar = UISearchBar()
        searchBar?.delegate = self
        navigationItem.titleView = searchBar

    }
}

extension NewsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedNews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NewsTableViewCell.self), for: indexPath) as? NewsTableViewCell
        cell?.configure(with: displayedNews[indexPath.row])
        return cell ?? UITableViewCell()
    }
}

extension NewsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO:       router.showDetails()
    }
}

extension NewsListViewController {
    
    func debounce<T>(delay: DispatchTimeInterval, queue: DispatchQueue = .main, action: @escaping ((T) -> Void)) -> (T) -> Void {
        var currentWorkItem: DispatchWorkItem?
        return { (parameter) in
            currentWorkItem?.cancel()
            let workItem = DispatchWorkItem {
                action(parameter)
            }
            currentWorkItem = workItem
            queue.asyncAfter(deadline: .now() + delay, execute: workItem)
        }
    }
}
extension NewsListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        tableView.refreshControl?.beginRefreshing()
        interactor?.getNewsList(request: NewsList.ShowNews.Request(keyWord: searchBar.text ?? ""))
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        lazySearch(searchText)
    }
    
}

extension NewsListViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}
