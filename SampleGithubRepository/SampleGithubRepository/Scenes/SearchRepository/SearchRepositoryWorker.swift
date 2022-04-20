//
//  SearchRepositoryWorker.swift
//  SampleGithubRepository
//

import UIKit
import MKUtils

protocol SearchRepositoryWorkerProtocol: AnyObject {
    func fetchRepository(name: String, page: Int, completion: @escaping (Result<Repositories, Error>) -> Void)
}

class SearchRepositoryWorker: SearchRepositoryWorkerProtocol {
    
    func fetchRepository(name: String, page: Int, completion: @escaping (Result<Repositories, Error>) -> Void) {
        let perPage = 30
        let endpoint = String.init(format: "https://api.github.com/search/repositories?q=%@&page=%dper_page=%d", name, page, perPage)
        let urlString = endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? endpoint
        guard let url = URL(string: urlString) else {return}
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let result: RepositoriesDTO = try JSONDecoder().decode(RepositoriesDTO.self, from: data)
                    let repos: [Repository] = result.items.map { el -> Repository in
                        return Repository(
                            id: el.id,
                            avatarURL: el.owner.avatarURL,
                            url: el.htmlURL,
                            fullName: el.fullName,
                            description: el.itemDescription,
                            starCount: el.stargazersCount,
                            watcherCount: el.watchersCount,
                            forkCount: el.forksCount
                            
                        )
                    }
                    let nextPage: Bool = (result.totalCount / perPage) > page
                    let nextPageIndex: Int? = nextPage ? (page + 1) : nil
                    let repo: Repositories = Repositories(totalCount: result.totalCount, incompleteResults: result.incompleteResults, currentPageIndex: page, nextPage: nextPageIndex, repos: repos)
                    completion(.success(repo))
                }
                catch let DecodingError.keyNotFound(_, context),
                      let DecodingError.valueNotFound(_, context),
                      let DecodingError.typeMismatch(_, context),
                      let DecodingError.dataCorrupted(context) {
                    
                    let error = APIError(error: context.debugDescription)
                    completion(.failure(error))
                }
                catch let error {
                    completion(.failure(error))
                }
            }
                        
        }.resume()
    }
    
    deinit {
        //
    }
}

