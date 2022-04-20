//
//  SearchRepositoryModels.swift
//  SampleGithubRepository
//

import UIKit

enum SearchRepository {
    // MARK: Use cases

    enum Search {
        // MARK: ViewController -> Interactor
        struct Request {
            var query: String
            var page: Int = 1
        }
        
        // MARK: Interactor -> Presenter
        struct Response {
            var repos: Repositories? = nil
            var error: Error? = nil
        }

        // MARK: Presenter -> ViewController
        struct ViewModel {
            var repos: Repositories? = nil
            var error: Error? = nil
        }
    }

}
