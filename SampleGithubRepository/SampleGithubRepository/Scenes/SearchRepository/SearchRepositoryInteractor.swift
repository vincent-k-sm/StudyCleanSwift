//
//  SearchRepositoryInteractor.swift
//  SampleGithubRepository
//

import UIKit

protocol SearchRepositoryBusinessLogic {
    func fetchRepos(request: SearchRepository.Search.Request)

}

protocol SearchRepositoryDataStore {
    //var name: String { get set }
}

class SearchRepositoryInteractor: SearchRepositoryBusinessLogic, SearchRepositoryDataStore {
    var presenter: SearchRepositoryPresentationLogic?
    var worker: SearchRepositoryWorker? = SearchRepositoryWorker(network: GitHubAPI())
    //var name: String = ""

    deinit {
        //
    }
    // MARK: Do something (and send response to SearchRepositoryPresenter)

    func fetchRepos(request: SearchRepository.Search.Request) {

        worker?.fetchRepository(name: request.query, page: request.page, completionHandler: { [weak self] result in
            switch result {
                case let .success(repo):
                    let response = SearchRepository.Search.Response(repos: repo)
                    self?.presenter?.presentFetchReposResult(response: response)
                    
                case let .failure(error):
                    let response = SearchRepository.Search.Response(error: error)
                    self?.presenter?.presentError(response: response)
            }
        })
    }

}
