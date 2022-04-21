//
//  SearchRepositoryInteractorTests.swift
//  SampleGithubRepository
//

@testable import SampleGithubRepository
import XCTest

class SearchRepositoryInteractorTests: XCTestCase
{
    // MARK: Subject under test

    var sut: SearchRepositoryInteractor!

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()
        setupSearchRepositoryInteractor()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Test setup

    func setupSearchRepositoryInteractor() {
        sut = SearchRepositoryInteractor()
    }

    // MARK: - Test doubles

    class SearchRepositoryPresentationLogicSpy: SearchRepositoryPresentationLogic
    {
        var presentFetchRepoResultCalled = false
        var presentErrorCalled = false
        
        func presentFetchReposResult(response: SearchRepository.Search.Response) {
            presentFetchRepoResultCalled = true
        }
        
        func presentError(response: SearchRepository.Search.Response) {
            presentErrorCalled = true
        }
        
    }
    
    class SearchRepositoryWorkerSpy: SearchRepositoryWorker {
        var fetchRepositoryCalled = false
        
        override func fetchRepository(name: String, page: Int, completionHandler completion: @escaping (Result<Repositories, Error>) -> Void) {
            
            let repositories: Repositories = Repositories(
                totalCount: 0,
                incompleteResults: false,
                currentPageIndex: 1,
                nextPage: nil,
                repos: []
            )
            fetchRepositoryCalled = true
            completion(.success(repositories))
        }
        
        
    }

    // MARK: - Tests

    func testFetchReposShouldAskSearchRepositoryWorkerToFetchReposAndPresenterToFormatResult() {
        // Given
        let spy = SearchRepositoryPresentationLogicSpy()
        sut.presenter = spy
        
        let workerSpy = SearchRepositoryWorkerSpy(network: GitHubAPI())
        sut.worker = workerSpy
        
        // When
        let request = SearchRepository.Search.Request(query: "", page: 1)
        sut.fetchRepos(request: request)

        // Then
        XCTAssertTrue(workerSpy.fetchRepositoryCalled, "fetchRepos() should ask SearchRepositoryWorker to fetch orders")
        
    }
}
