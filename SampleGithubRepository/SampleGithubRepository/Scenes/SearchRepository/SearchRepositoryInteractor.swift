//
//  SearchRepositoryInteractor.swift
//  SampleGithubRepository
//

import UIKit

protocol SearchRepositoryBusinessLogic {
    func doSomething(request: SearchRepository.Something.Request)
//    func doSomethingElse(request: SearchRepository.SomethingElse.Request)
}

protocol SearchRepositoryDataStore {
    //var name: String { get set }
}

class SearchRepositoryInteractor: SearchRepositoryBusinessLogic, SearchRepositoryDataStore {
    var presenter: SearchRepositoryPresentationLogic?
    var worker: SearchRepositoryWorker?
    //var name: String = ""

    deinit {
        //
    }
    // MARK: Do something (and send response to SearchRepositoryPresenter)

    func doSomething(request: SearchRepository.Something.Request) {
        worker = SearchRepositoryWorker()
        worker?.doSomeWork()

        let response = SearchRepository.Something.Response()
        presenter?.presentSomething(response: response)
    }
//
//    func doSomethingElse(request: SearchRepository.SomethingElse.Request) {
//        worker = SearchRepositoryWorker()
//        worker?.doSomeOtherWork()
//
//        let response = SearchRepository.SomethingElse.Response()
//        presenter?.presentSomethingElse(response: response)
//    }
}
