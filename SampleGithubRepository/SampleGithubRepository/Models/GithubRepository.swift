//
//  GithubRepository.swift
//


import Foundation
import UIKit
import MKUtils

struct Repositories: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    var currentPageIndex: Int
    var nextPage: Int?
    var repos: [Repository]

}

struct Repository: Codable, Equatable, SearchRepositoryTableViewCellModel {
    
    let id: Int
    let avatarURL: String
    let url: String
    let fullName: String
    let description: String
    let starCount: Int
    let watcherCount: Int
    let forkCount: Int
    
    var repositoryName: String {
        get {
            return self.fullName
        }
    }
    
    func fetchImage(completion: @escaping (Result<UIImage, ImageFetchingError>) -> Void) {
        var result: Result<UIImage, ImageFetchingError>!
        
        let urlString = self.avatarURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self.avatarURL
        guard let url = URL(string: urlString) else {
            completion(.failure(.unknown))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10

        DispatchQueue.global(qos: .background).async {
            URLSession(configuration: sessionConfig).dataTask(with: url) { data, _, error in
                if let data = data, let image = UIImage(data: data) {
                    result = .success(image)
                }
                if let error = error {
                    if (error as? URLError)?.code == .timedOut {
                        result = .failure(.timeout)
                    }
                    else {
                        result = .failure(.unknown)
                    }
                    
                }
                completion(result)
            }.resume()
        }
        
        
        
//        let semaphore = DispatchSemaphore(value: 0)
//
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            if let data = data, let image = UIImage(data: data) {
//                result = .success(image)
//            }
//            if let error = error {
//                if (error as? URLError)?.code == .timedOut {
//                    result = .failure(.timeout)
//                }
//                else {
//                    result = .failure(.unknown)
//                }
//
//            }
//            semaphore.signal()
////            completion(result)
//        }.resume()
        
//        if semaphore.wait(timeout: .now() + 0.01) == .timedOut {
//            result = .failure(.timeout)
//            completion(result)
//        }
//        else {
//            completion(result)
//        }
        
        
    }
}
