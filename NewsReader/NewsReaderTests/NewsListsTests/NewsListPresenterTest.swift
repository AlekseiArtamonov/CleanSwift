//
//  NewsListPresenterTest.swift
//  NewsReaderTests
//
//  Created by Aleksei Artamonov on 7/16/19.
//  Copyright © 2019 test. All rights reserved.
//

@testable import NewsReader
import XCTest

class NewsListPresenterTest: XCTestCase {
    
    enum InternalError: Error, LocalizedError {
        case newsLoadingError (desctiption: String)
    }
    
    private class NewsListViewControllerMock: NewsListViewController {
        var displayedNews: [NewsList.ShowNews.ViewModel.FeedViewModel]?
        var displayedError: String?
        var expectation: XCTestExpectation?
        override func displayNews(viewModel: NewsList.ShowNews.ViewModel) {
            DispatchQueue.main.async {
                self.displayedNews = viewModel.displayedFeeds
                self.expectation?.fulfill()
            }
        }
        
        override func displayError(viewModel: NewsList.ShowError.ErrorViewModel) {
            DispatchQueue.main.async {
                self.displayedError = viewModel.errorDescription
                self.expectation?.fulfill()
            }
        }
    }

    func testPresentingNews() {
        // init
        let viewControllerMock = NewsListViewControllerMock()
        viewControllerMock.expectation = XCTestExpectation(description: "testPresentingNewsExpectation")
        let presenter = NewsListPresenter(viewController: viewControllerMock)
        var feedsResponse = NewsList.ShowNews.Response(articles: [])
        if let filePath = Bundle(for: NewsListInteractorTest.self).path(forResource: "response_body", ofType: "json"), let data = NSData(contentsOfFile: filePath) {
            do {
                let response = try JSONDecoder().decode(FeedServerResponse.self, from: data as Data)
                feedsResponse = NewsList.ShowNews.Response(articles: response.articles ?? [])
            }
            catch {
                XCTFail("unable to parse json")
            }
        } else {
            XCTFail("unable to parse from resource file")
        }
        // test
        presenter.presentNews(feedsResponse)
        if let expectation = viewControllerMock.expectation {
            wait(for: [expectation], timeout: 2.0)
        }
        // check
        XCTAssert(viewControllerMock.displayedNews?.count == 20)
        XCTAssert(viewControllerMock.displayedError == nil)
        
        //check parsing in of response and composing viewModel
        XCTAssertEqual(viewControllerMock.displayedNews?.first?.title, "Bitcoin New York")
        XCTAssertEqual(viewControllerMock.displayedNews?.first?.resource, "Slashdot.org")
        XCTAssertEqual(viewControllerMock.displayedNews?.first?.description, "NewYorkCoin (NYC) is lightning fast and free cryptocurrency since 2014. Bitcoin for New York, and beyond.")
        XCTAssertEqual(viewControllerMock.displayedNews?.first?.publishDate, "16.07.2019")
        XCTAssert(viewControllerMock.displayedNews?.first?.image != nil)
        
        
    }
    
    func testPresentingError() {
        // init
        let viewControllerMock = NewsListViewControllerMock()
        viewControllerMock.expectation = XCTestExpectation(description: "testPresentingNewsExpectation")
        let presenter = NewsListPresenter(viewController: viewControllerMock)
        
        // test
        presenter.presentError(InternalError.newsLoadingError(desctiption: "Error"))
        if let expectation = viewControllerMock.expectation {
            wait(for: [expectation], timeout: 2.0)
        }
        // check
        XCTAssert(viewControllerMock.displayedNews == nil)
        XCTAssert(viewControllerMock.displayedError != nil)
    }
}
