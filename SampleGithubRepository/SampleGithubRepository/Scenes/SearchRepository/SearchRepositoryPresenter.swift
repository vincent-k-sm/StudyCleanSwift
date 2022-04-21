//
//  SearchRepositoryPresenter.swift
//  SampleGithubRepository
//

import UIKit

protocol SearchRepositoryPresentationLogic {
    func presentFetchReposResult(response: SearchRepository.Search.Response)
    func presentError(response: SearchRepository.Search.Response)
}

class SearchRepositoryPresenter: SearchRepositoryPresentationLogic {
    
    
    weak var viewController: SearchRepositoryDisplayLogic?

    // MARK: Parse and calc respnse from SearchRepositoryInteractor and send simple view model to SearchRepositoryViewController to be displayed

    deinit {
        //
    }
    
    func presentFetchReposResult(response: SearchRepository.Search.Response) {
        
        let viewModel = SearchRepository.Search.ViewModel(repos: response.repos, error: nil)
        viewController?.displayFetchOrderResult(viewModel: viewModel)
        
    }
    
    func presentError(response: SearchRepository.Search.Response) {
        let viewModel = SearchRepository.Search.ViewModel(repos: nil, error: response.error)
        viewController?.displayErrorAlert(viewModel: viewModel)
    }
    
}
