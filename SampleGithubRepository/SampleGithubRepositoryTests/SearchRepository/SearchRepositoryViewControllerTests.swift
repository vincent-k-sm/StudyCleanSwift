//
//  SearchRepositoryViewControllerTests.swift
//  SampleGithubRepository
//

@testable import SampleGithubRepository
import XCTest
import MKUtils

class SearchRepositoryViewControllerTests: XCTestCase {
    // MARK: Subject under test

    var sut: SearchRepositoryViewController!
    var window: UIWindow!

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupSearchRepositoryViewController()
    }

    override func tearDown() {
        window = nil
        super.tearDown()
    }

    // MARK: - Test setup

    func setupSearchRepositoryViewController() {
        sut = SearchRepositoryViewController()
    }

    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }

    // MARK: - Test doubles

    class SearchRepositoryBusinessLogicSpy: SearchRepositoryBusinessLogic {
        var searchReopsCalled = false
        func fetchRepos(request: SearchRepository.Search.Request) {
            searchReopsCalled = true
        }
    }
    
    class TableViewSpy: UITableView {
        var reloadDataCalled = false
        var insertRowCalled = false
        
        override func reloadData() {
            super.reloadData()
            reloadDataCalled = true
        }
        
        override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
            super.insertRows(at: indexPaths, with: animation)
            insertRowCalled = true
        }
    }

    // MARK: - Tests

    func testShouldDoSomethingWhenViewIsLoaded() {
        // Given
        let spy = SearchRepositoryBusinessLogicSpy()
        sut.interactor = spy

        // When
        loadView()

        // Then
        XCTAssertFalse(spy.searchReopsCalled, "viewDidLoad() should not ask anything to interactor")
    }
    
    func testDisplayFetchOrderResult() {
        // given
        let tableViewSpy = TableViewSpy()
        sut.tableView = tableViewSpy
        sut.tableView.dataSource = sut
        
        let expect = expectation(description: "Wait for tableview run in DispatchQueue.main.async")
        
        let count = 10
        let repoList: [Repository] = (0..<count).map({ el -> Repository in
            return Repository(id: el, avatarURL: "", url: "", fullName: "", description: "", starCount: 0, watcherCount: 0, forkCount: 0)
        })
        
        let repos: Repositories = Repositories(
            totalCount: count,
            incompleteResults: false,
            currentPageIndex: 1,
            nextPage: nil,
            repos: repoList
        )
        let viewmodel = SearchRepository.Search.ViewModel(repos: repos)
        
        // when
        sut.displayFetchOrderResult(viewModel: viewmodel)
        DispatchQueue.main.async {
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 2.0)
        
        // then
        XCTAssert(tableViewSpy.reloadDataCalled, "tableView reloaded when displayfetchorders")
    
        XCTAssertEqual(sut.repos?.repos.count, tableViewSpy.numberOfRows(inSection: 0), "repos count should equal tableview row count")
        
    }
    
    func testDisplayFetchOrderResultWhenAppend() {
        // given
        let tableViewSpy = TableViewSpy()
        sut.tableView = tableViewSpy
        sut.tableView.dataSource = sut

        let expect = expectation(description: "Wait for tableview run in DispatchQueue.main.async")
        
        let count = 10
        let repoList: [Repository] = (0..<count).map({ el -> Repository in
            return Repository(id: el, avatarURL: "", url: "", fullName: "", description: "", starCount: 0, watcherCount: 0, forkCount: 0)
        })
        
        let repos: Repositories = Repositories(
            totalCount: count,
            incompleteResults: false,
            currentPageIndex: 1,
            nextPage: nil,
            repos: repoList
        )
        var viewmodel = SearchRepository.Search.ViewModel(repos: repos)
        
        // when
        sut.displayFetchOrderResult(viewModel: viewmodel)
        viewmodel.repos?.currentPageIndex = 2
        sut.displayFetchOrderResult(viewModel: viewmodel)
        
        DispatchQueue.main.async {
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 2.0)
        
        // then
        XCTAssert(tableViewSpy.insertRowCalled, "tableView should insert row when displayfetchorders paging")
        XCTAssertEqual(sut.repos?.repos.count, sut.tableView.numberOfRows(inSection: 0), "repos count should equal tableview row count")
    }
}
