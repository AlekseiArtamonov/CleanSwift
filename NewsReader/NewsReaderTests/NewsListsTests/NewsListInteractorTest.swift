//
//  NewsListInteractorTest.swift
//  NewsReaderTests
//
//  Created by Aleksei Artamonov on 7/16/19.
//  Copyright © 2019 test. All rights reserved.
//
@testable import NewsReader

import XCTest

class NewsListInteractorTest: XCTestCase {

    enum InternalError: Error, LocalizedError {
        case newsLoadingError (desctiption: String)
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
    
    private class NewsListWorkerMock: NewsListWorking {
        func getNewsList(with request: NewsList.ShowNews.Request, completion: @escaping (Result<[Article], Error>) -> Void) {
            DispatchQueue.global().async {
                if request.keyWord == "Error" {
                    completion(.failure(InternalError.newsLoadingError(desctiption: "Error")))
                } else {
                    if let filePath = Bundle(for: NewsListInteractorTest.self).path(forResource: "response_body", ofType: "json"), let data = NSData(contentsOfFile: filePath) {
                        do {
                            let feedsResponse = try JSONDecoder().decode(FeedServerResponse.self, from: data as Data)
                            completion(.success(feedsResponse.articles ?? []))
                        }
                        catch {
                            XCTFail("unable to parse json")
                        }
                    } else {
                        completion(.failure(InternalError.newsLoadingError(desctiption: "unable to parse response")))
                    }
                }
            }
        }
        
        func loadImage(with url: URL, completion: @escaping (UIImage?) -> Void) {
            DispatchQueue.global().async {
                completion(UIImage())
            }
        }
    }
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoadingNews() {
        // init
        let workerMock = NewsListWorkerMock()
        let presenterMock = NewsListPresenterMock()
        presenterMock.expectation = XCTestExpectation(description: "testLoadingNewsExpectation")
        let interactor = NewsListInteractor(worker: workerMock, presenter: presenterMock)
        
        // test
        interactor.getNewsList(request: NewsList.ShowNews.Request(keyWord: "some"))
        if let expectation = presenterMock.expectation {
            wait(for: [expectation], timeout: 2.0)
        }
        // check
        XCTAssertEqual(presenterMock.presentedNews?.articles.count, 20)
        XCTAssert(presenterMock.presentedError == nil)
    }

    func testLoadingNewsFail() {
        // init
        let workerMock = NewsListWorkerMock()
        let presenterMock = NewsListPresenterMock()
        presenterMock.expectation = XCTestExpectation(description: "testLoadingNewsFailExpectation")
        let interactor = NewsListInteractor(worker: workerMock, presenter: presenterMock)
        
        // test
        interactor.getNewsList(request: NewsList.ShowNews.Request(keyWord: "Error"))
        if let expectation = presenterMock.expectation {
            wait(for: [expectation], timeout: 2.0)
        }
        // check
        XCTAssert(presenterMock.presentedError != nil)
        XCTAssert(presenterMock.presentedNews == nil)
    }
}
