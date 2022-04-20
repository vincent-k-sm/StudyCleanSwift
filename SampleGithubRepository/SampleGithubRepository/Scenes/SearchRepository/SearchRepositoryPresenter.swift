//
//  SearchRepositoryPresenter.swift
//  SampleGithubRepository
//

import UIKit

protocol SearchRepositoryPresentationLogic {
    func presentSomething(response: SearchRepository.Something.Response)
}

class SearchRepositoryPresenter: SearchRepositoryPresentationLogic {
    weak var viewController: SearchRepositoryDisplayLogic?

    // MARK: Parse and calc respnse from SearchRepositoryInteractor and send simple view model to SearchRepositoryViewController to be displayed

    deinit {
        //
    }
    
    func presentSomething(response: SearchRepository.Something.Response) {
        let viewModel = SearchRepository.Something.ViewModel()
        viewController?.displaySomething(viewModel: viewModel)
    }
//
//    func presentSomethingElse(response: SearchRepository.SomethingElse.Response) {
//        let viewModel = SearchRepository.SomethingElse.ViewModel()
//        viewController?.displaySomethingElse(viewModel: viewModel)
//    }
}
