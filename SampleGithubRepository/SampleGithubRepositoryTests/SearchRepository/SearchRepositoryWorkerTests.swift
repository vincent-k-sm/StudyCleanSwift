//
//  SearchRepositoryWorkerTests.swift
//  SampleGithubRepository
//

@testable import SampleGithubRepository
import XCTest

class SearchRepositoryWorkerTests: XCTestCase
{
    // MARK: Subject under test
  
    var sut: SearchRepositoryWorker!
    static var apiSuccess: Bool = true
    static var result: Repositories? = nil
    
    // MARK: - Test lifecycle
  
    override func setUp() {
        super.setUp()
        setupSearchRepositoryWorker()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Test setup
  
    func setupSearchRepositoryWorker() {
        sut = SearchRepositoryWorker(network: GitHubAPISpy())
        
        let repos: [Repository] = (0..<30).map { el -> Repository in
            return Repository(id: el, avatarURL: "image", url: "\(el)url", fullName: "\(el) fullName \(name)", description: "\(el) description", starCount: el, watcherCount: el, forkCount: el)
        }
        let repositories: Repositories = Repositories(
            totalCount: repos.count,
            incompleteResults: false,
            currentPageIndex: 1,
            nextPage: nil,
            repos: repos
        )
        
        SearchRepositoryWorkerTests.result = repositories
    }

    // MARK: - Test doubles
    class GitHubAPISpy: GitHubAPI {
        var fetchReposCalled = false
        var fetchReposFailed = false
        var fetchReposSucceed = false
        
        override func fetchRepository(name: String, page: Int, completion: @escaping (Result<Repositories, Error>) -> Void) {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                if SearchRepositoryWorkerTests.apiSuccess {
                    if let result = SearchRepositoryWorkerTests.result {
                        self.fetchReposSucceed = true
                        completion(.success(result))
                    }
                    else {
                        let error = APIError(error: "API Mock Error")
                        self.fetchReposFailed = true
                        completion(.failure(error))
                    }
                }
                else {
                    let error = APIError(error: "API Error")
                    self.fetchReposFailed = true
                    completion(.failure(error))
                }
            }
            fetchReposCalled = true
        }
    }
    
    // MARK: - Tests
  
    func testfetchRepositorySuccess() {
        // Given
        let spy = sut.network as! GitHubAPISpy
        SearchRepositoryWorkerTests.apiSuccess = true
        
        // When
        var fetchedRepos = [Repository]()
        var fetchedError: Error? = nil
        let expect = expectation(description: "Wait for fetchedRepos() to return")
        sut.fetchRepository(name: "test", page: 1) { result in
            switch result {
                case let .success(repos):
                    fetchedRepos = repos.repos
                case let .failure(error):
                    fetchedError = error
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.1)
        // Then
        XCTAssert(spy.fetchReposCalled, "Calling fetchRepos() should ask the data store for a list of repos")
        XCTAssert(spy.fetchReposSucceed, "Calling fetchRepos() should called succeed")
        XCTAssert(!spy.fetchReposFailed, "Calling fetchRepos() should not called failed")
        XCTAssertEqual(fetchedRepos.count, SearchRepositoryWorkerTests.result?.repos.count, "fetchRepos() should return a list of repos")
        for repo in fetchedRepos {
            XCTAssert(SearchRepositoryWorkerTests.result!.repos.filter({ $0 == repo }).count >= 1, "Fetched repos should match the repos in the data store")
        }
        XCTAssert(fetchedError == nil, "Calling fetchRepos() should not have error result")
    }
    
    func testfetchRepositoryFailure() {
        // Given
        let spy = sut.network as! GitHubAPISpy
        SearchRepositoryWorkerTests.apiSuccess = false
        
        // When
        var fetchedRepos = [Repository]()
        var fetchedError: Error? = nil
        let expect = expectation(description: "Wait for fetchedRepos() to return")
        
        sut.fetchRepository(name: "test", page: 1) { result in
            switch result {
                case let .success(repos):
                    fetchedRepos = repos.repos
                case let .failure(error):
                    fetchedError = error
                    
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 2.0)
        
        // Then
        XCTAssert(spy.fetchReposCalled, "Calling fetchRepos() should ask the data store for a list of repos")
        XCTAssert(!spy.fetchReposSucceed, "Calling fetchRepos() should not called succeed")
        XCTAssert(spy.fetchReposFailed, "Calling fetchRepos() should called failed")
        XCTAssertEqual(fetchedRepos.count, 0, "fetchRepos() should not return a list of repos")
        XCTAssert(fetchedError != nil, "Calling fetchRepos() should have error result")
    }
}
