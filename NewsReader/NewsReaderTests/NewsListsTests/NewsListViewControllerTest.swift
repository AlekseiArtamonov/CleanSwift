//
//  NewsListViewControllerTest.swift
//  NewsReaderTests
//
//  Created by Aleksei Artamonov on 7/16/19.
//  Copyright © 2019 test. All rights reserved.
//

@testable import NewsReader
import XCTest

class NewsListViewControllerTest: XCTestCase {

    enum InternalError: Error, LocalizedError {
        case newsLoadingError (desctiption: String)
    }
    var newsListViewController: NewsListViewController?
    override func setUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        newsListViewController = (storyboard.instantiateViewController(withIdentifier: "NewsListViewController") as? NewsListViewController)
    }
    
    private class NewsListPresenterMock: NewsListPresenting {
        var presentedNews: NewsList.ShowNews.Response?
        var presentedError: Error?
        var expectation: XCTestExpectation?
        func presentError(_ error: Error) {
            presentedError = error
            expectation?.fulfill()
        }
        
        func presentNews(_ response: NewsList.ShowNews.Response) {
            presentedNews = response
            expectation?.fulfill()
        }
    }
    
    private class NewsListRouterMock: NewsListRouting {
        var errorMessage: String?
        var expectation: XCTestExpectation?
        
        init(expectation: XCTestExpectation? = nil) {
            self.expectation = expectation
        }
        
        func showError(message: String) {
            errorMessage = message
            expectation?.fulfill()
        }
    }
    
    private class NewsListInteractorMock: NewsListInteracting {
        var request: NewsList.ShowNews.Request?
        var expectation: XCTestExpectation?
        
        init(expectation: XCTestExpectation? = nil) {
            self.expectation = expectation
        }
        
        func getNewsList(request: NewsList.ShowNews.Request) {
            self.request = request
            expectation?.fulfill()
        }
        
        
    }
    
    private class TableViewMock: UITableView {
        var isTableViewReloaded = false
        var expectation: XCTestExpectation?
        override func reloadData() {
            isTableViewReloaded = true
            expectation?.fulfill()
        }
    }
    
    func testSearchOnLoading() {
        guard let newsListViewController = newsListViewController else {
            XCTFail("newsListViewController is nil")
            return
        }
        let expectation = XCTestExpectation(description: "testLoadingNewsExpectation")
        let interactor = NewsListInteractorMock(expectation: expectation)
        newsListViewController.router = NewsListRouterMock()
        newsListViewController.interactor = interactor
        _ = newsListViewController.view


        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(interactor.request?.keyWord, "")
    }
    
    func testLazySearchOnSearchBarFilling() {
        guard let newsListViewController = newsListViewController else {
            XCTFail("newsListViewController is nil")
            return
        }
        let expectation = XCTestExpectation(description: "testLazySearchOnSearchBarFillingExpectation")
        let interactor = NewsListInteractorMock(expectation: expectation)
        newsListViewController.router = NewsListRouterMock()
        newsListViewController.interactor = interactor
        _ = newsListViewController.view
        
        wait(for: [expectation], timeout: 2.0)
        let expectation2 = XCTestExpectation(description: "testLazySearchOnSearchBarFillingExpectation2")
        interactor.expectation = expectation2
        let testString = "test"
        guard let searchBar = newsListViewController.searchBar else {
            XCTFail("searchBar is nil")
            return
        }
        searchBar.delegate?.searchBar?(searchBar, textDidChange: testString)
        wait(for: [expectation2], timeout: 2.0)
        XCTAssertEqual(interactor.request?.keyWord, testString)
    }
    
    func testSearchOnSearchButton() {
        guard let newsListViewController = newsListViewController else {
            XCTFail("newsListViewController is nil")
            return
        }
        let expectation = XCTestExpectation(description: "testLazySearchOnSearchBarFillingExpectation")
        let interactor = NewsListInteractorMock(expectation: expectation)
        newsListViewController.router = NewsListRouterMock()
        newsListViewController.interactor = interactor
        _ = newsListViewController.view
        
        wait(for: [expectation], timeout: 2.0)
        let expectation2 = XCTestExpectation(description: "testLazySearchOnSearchBarFillingExpectation2")
        interactor.expectation = expectation2
        let testString = "test"
        guard let searchBar = newsListViewController.searchBar else {
            XCTFail("searchBar is nil")
            return
        }
        searchBar.text = testString
        searchBar.delegate?.searchBarSearchButtonClicked?(searchBar)
        wait(for: [expectation2], timeout: 2.0)
        XCTAssertEqual(interactor.request?.keyWord, testString)
    }
    
    func testRefreshControlSearch() {
        guard let newsListViewController = newsListViewController else {
            XCTFail("newsListViewController is nil")
            return
        }
        let expectation = XCTestExpectation(description: "testRefreshControlSearcExpectation")
        let interactor = NewsListInteractorMock(expectation: expectation)
        newsListViewController.router = NewsListRouterMock()
        newsListViewController.interactor = interactor
        _ = newsListViewController.view
        
        wait(for: [expectation], timeout: 2.0)
        let expectation2 = XCTestExpectation(description: "testRefreshControlSearchExpectation2")
        interactor.expectation = expectation2
        guard let refreshControl = newsListViewController.tableView.refreshControl else {
            XCTFail("no refresh control")
            return
        }
        newsListViewController.refreshOnControl(refreshControl)
        wait(for: [expectation2], timeout: 2.0)
        XCTAssertEqual(interactor.request?.keyWord, "")
    }
    
    func testRefreshControlTable() {
        guard let newsListViewController = newsListViewController else {
            XCTFail("newsListViewController is nil")
            return
        }
        let expectation = XCTestExpectation(description: "testRefreshControlSearcExpectation")
        let interactor = NewsListInteractorMock(expectation: expectation)
        newsListViewController.router = NewsListRouterMock()
        newsListViewController.interactor = interactor
        _ = newsListViewController.view
        
        wait(for: [expectation], timeout: 2.0)
        let expectation2 = XCTestExpectation(description: "testRefreshControlSearchExpectation2")
        interactor.expectation = expectation2
        guard let refreshControl = newsListViewController.tableView.refreshControl else {
            XCTFail("no refresh control")
            return
        }
        newsListViewController.refreshOnControl(refreshControl)
        wait(for: [expectation2], timeout: 2.0)
        XCTAssertEqual(interactor.request?.keyWord, "")
    }
    
    func testDisplayNews() {
        guard let newsListViewController = newsListViewController else {
            XCTFail("newsListViewController is nil")
            return
        }
        let expectation = XCTestExpectation(description: "testDisplayNewsExpectation")
        let interactor = NewsListInteractorMock(expectation: expectation)
        newsListViewController.router = NewsListRouterMock()
        newsListViewController.interactor = interactor
        _ = newsListViewController.view
        wait(for: [expectation], timeout: 2.0)
        let tableViewMock = TableViewMock()
        tableViewMock.register(NewsTableViewCell.self, forCellReuseIdentifier: "NewsTableViewCell")
        let expectation2 = XCTestExpectation(description: "testDisplayNewsExpectation2")
        tableViewMock.expectation = expectation2
        newsListViewController.tableView = tableViewMock
       
        let image = UIImage()
        newsListViewController.displayNews(viewModel: NewsList.ShowNews.ViewModel(displayedFeeds: [NewsList.ShowNews.ViewModel.FeedViewModel(title: "title", resource: "resourse", image: image, description: "description", publishDate: "date")]))
        wait(for: [expectation2], timeout: 2.0)
        
        XCTAssert(tableViewMock.isTableViewReloaded)
        XCTAssertEqual(newsListViewController.tableView(tableViewMock, numberOfRowsInSection: 0), 1)
    }
    
    func testConfigureCell() {
        guard let newsListViewController = newsListViewController else {
            XCTFail("newsListViewController is nil")
            return
        }
        let expectation = XCTestExpectation(description: "testConfigureCellExpectation")
        let interactor = NewsListInteractorMock(expectation: expectation)
        newsListViewController.router = NewsListRouterMock()
        newsListViewController.interactor = interactor
        _ = newsListViewController.view
        wait(for: [expectation], timeout: 2.0)
        let image = UIImage()
        newsListViewController.displayNews(viewModel: NewsList.ShowNews.ViewModel(displayedFeeds: [NewsList.ShowNews.ViewModel.FeedViewModel(title: "title", resource: "resource", image: image, description: "description", publishDate: "date")]))
        let expectation2 = XCTestExpectation(description: "testConfigureCellExpectation2")
        DispatchQueue.main.async {
            guard let cell = newsListViewController.tableView(newsListViewController.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? NewsTableViewCell else {
                XCTFail("NewsTableViewCell is nil")
                return
            }
            XCTAssertEqual(cell.titleLabel.text, "title")
            XCTAssertEqual(cell.resourceLabel.text, "resource")
            XCTAssertEqual(cell.descriptionLabel.text, "description")
            XCTAssertEqual(cell.publishDateLabel.text,"date")
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 2.0)
    }
    func testDisplayError() {
        guard let newsListViewController = newsListViewController else {
            XCTFail("newsListViewController is nil")
            return
        }
        let expectation = XCTestExpectation(description: "testDisplayErrorExpectation")
        let router = NewsListRouterMock(expectation: expectation)
        newsListViewController.router = router
        newsListViewController.interactor = NewsListInteractorMock()
        
        newsListViewController.displayError(viewModel: .init(errorDescription: "Error"))
        
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(router.errorMessage, "Error")
    }
}
