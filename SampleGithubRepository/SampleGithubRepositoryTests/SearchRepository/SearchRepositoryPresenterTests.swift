//
//  SearchRepositoryPresenterTests.swift
//  SampleGithubRepository
//

@testable import SampleGithubRepository
import XCTest

class SearchRepositoryPresenterTests: XCTestCase {
    // MARK: Subject under test

    var sut: SearchRepositoryPresenter!

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()
        setupSearchRepositoryPresenter()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Test setup

    func setupSearchRepositoryPresenter() {
        sut = SearchRepositoryPresenter()
    }

    // MARK: - Test doubles

    class SearchRepositoryDisplayLogicSpy: SearchRepositoryDisplayLogic {
        var displayFetchOrderResultCalled = false
        var displayErrorAlertCalled = false
        
        func displayFetchOrderResult(viewModel: SearchRepository.Search.ViewModel) {
            displayFetchOrderResultCalled = true
        }
        
        func displayErrorAlert(viewModel: SearchRepository.Search.ViewModel) {
            displayErrorAlertCalled = true
        }
        
    }

    // MARK: - Tests

    func testPresentFetchReposResult() {
        // Given
        let spy = SearchRepositoryDisplayLogicSpy()
        sut.viewController = spy
        
        let successResult: Repositories = Repositories(
            totalCount: 0,
            incompleteResults: false,
            currentPageIndex: 1,
            nextPage: nil,
            repos: []
        )
        let successResponse = SearchRepository.Search.Response(repos: successResult)

        // When
        sut.presentFetchReposResult(response: successResponse)
        
        // then
        XCTAssert(spy.displayFetchOrderResultCalled, "presenting success should ask view controller to display them")
        XCTAssertFalse(spy.displayErrorAlertCalled, "presenting error should not ask view controller to display them")
        
    }
    
    func testPresentError() {
        // Given
        let spy = SearchRepositoryDisplayLogicSpy()
        sut.viewController = spy
        
        let failureResult = APIError(error: "completion with Error")
        let failureResponse = SearchRepository.Search.Response(error: failureResult)

        // When
        sut.presentError(response: failureResponse)
        
        // then
        XCTAssertFalse(spy.displayFetchOrderResultCalled, "presenting success should not ask view controller to display them")
        XCTAssert(spy.displayErrorAlertCalled, "presenting failure should ask view controller to display them")
        
    }
}
