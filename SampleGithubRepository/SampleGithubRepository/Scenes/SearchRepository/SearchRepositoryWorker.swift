//
//  SearchRepositoryWorker.swift
//  SampleGithubRepository
//

import UIKit
import MKUtils

class SearchRepositoryWorker {
    
    var network: SearchRepositoryWorkerProtocol
    
    init(
        network: SearchRepositoryWorkerProtocol
    ) {
        self.network = network
    }
    
    func fetchRepository(name: String, page: Int, completionHandler: @escaping (Result<Repositories, Error>) -> Void) {
        self.network.fetchRepository(name: name, page: page, completion: { completion in
            completionHandler(completion)
        })
    }
    
    deinit {
        //
    }
}

